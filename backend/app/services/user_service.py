from datetime import datetime, timezone

from bson import ObjectId
from fastapi import HTTPException, status

from app.core.security import hash_password, verify_password, create_short_lived_token, decode_access_token
from app.services.email_service import send_verification_email, send_password_changed_email, send_reset_password_email
from app.db.mongodb import db
from app.schemas.user import UserCreate, UserResponse, UserUpdate

users_collection = db["users"]


def user_to_response(user: dict) -> UserResponse:
    return UserResponse(
        id=str(user["_id"]),
        name=user.get("name") or "",
        email=user.get("email") or "",
        provider=user.get("provider") or "local",
        gender=user.get("gender") or "unknown",
        date_of_birth=user.get("date_of_birth"),
        theme=user.get("theme") or "light",
        photo_url=user.get("photo_url"),
        face_image=user.get("face_image"),
        is_verified=bool(user.get("is_verified", False)),
    )


def get_user_by_email(email: str) -> dict | None:
    return users_collection.find_one({"email": email.lower()})


def get_user_by_id(user_id: str) -> dict | None:
    if not ObjectId.is_valid(user_id):
        return None
    return users_collection.find_one({"_id": ObjectId(user_id)})


def list_users() -> list[UserResponse]:
    users = users_collection.find({}, {"hashed_password": 0})
    return [user_to_response(user) for user in users]


def create_user(data: UserCreate) -> UserResponse:
    email = data.email.lower()

    if get_user_by_email(email):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email sudah terdaftar",
        )

    user_doc = {
        "name": data.name.strip(),
        "email": email,
        "hashed_password": hash_password(data.password),
        "provider": "local",
        "gender": data.gender or "unknown",
        "date_of_birth": data.date_of_birth,
        "theme": "light",
        "photo_url": None,
        "is_verified": False,
        "created_at": datetime.now(timezone.utc),
    }

    result = users_collection.insert_one(user_doc)
    user_doc["_id"] = result.inserted_id
    
    # Send verification email
    token = create_short_lived_token(email, minutes=60)
    send_verification_email(email, token)
    
    return user_to_response(user_doc)


def get_user_by_google_id(google_id: str) -> dict | None:
    return users_collection.find_one({"google_id": google_id})


def authenticate_user(email: str, password: str) -> dict:
    user = get_user_by_email(email.lower())
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email atau password salah",
        )

    if user.get("provider") == "google":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Akun ini terdaftar via Google. Silakan login dengan Google.",
        )

    hashed = user.get("hashed_password")
    if not hashed or not verify_password(password, hashed):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email atau password salah",
        )
    return user


def login_or_register_with_google(id_token: str) -> dict:
    from app.services.google_auth_service import verify_google_id_token

    try:
        idinfo = verify_google_id_token(id_token)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
        ) from exc

    email = idinfo["email"].lower()
    google_id = idinfo["sub"]
    name = idinfo.get("name") or email.split("@")[0]
    photo_url = idinfo.get("picture")
    is_verified = bool(idinfo.get("email_verified", False))

    user = get_user_by_google_id(google_id) or get_user_by_email(email)
    now = datetime.now(timezone.utc)

    if user:
        users_collection.update_one(
            {"_id": user["_id"]},
            {
                "$set": {
                    "name": name,
                    "email": email,
                    "provider": "google",
                    "google_id": google_id,
                    "photo_url": photo_url,
                    "is_verified": is_verified,
                    "updated_at": now,
                }
            },
        )
        user = get_user_by_id(str(user["_id"]))
    else:
        user_doc = {
            "name": name,
            "email": email,
            "provider": "google",
            "google_id": google_id,
            "gender": "unknown",
            "date_of_birth": None,
            "theme": "light",
            "photo_url": photo_url,
            "is_verified": is_verified,
            "created_at": now,
        }
        result = users_collection.insert_one(user_doc)
        user_doc["_id"] = result.inserted_id
        user = user_doc

    return user


def update_user(user_id: str, data: UserUpdate) -> UserResponse:
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan",
        )

    update_data: dict = {}

    if data.name is not None:
        update_data["name"] = data.name.strip()

    if data.email is not None:
        new_email = data.email.lower()
        existing = get_user_by_email(new_email)
        if existing and str(existing["_id"]) != user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email sudah digunakan user lain",
            )
        update_data["email"] = new_email

    if data.gender is not None:
        update_data["gender"] = data.gender

    if data.date_of_birth is not None:
        update_data["date_of_birth"] = data.date_of_birth

    if data.theme is not None:
        update_data["theme"] = data.theme

    if data.password is not None:
        if data.password != data.confirm_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Password dan konfirmasi password tidak cocok",
            )
        update_data["hashed_password"] = hash_password(data.password)

    if not update_data:
        return user_to_response(user)

    users_collection.update_one({"_id": user["_id"]}, {"$set": update_data})
    
    if "hashed_password" in update_data:
        send_password_changed_email(user["email"])
        
    updated = get_user_by_id(user_id)
    return user_to_response(updated)


def delete_user(user_id: str) -> None:
    if not ObjectId.is_valid(user_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan",
        )

    result = users_collection.delete_one({"_id": ObjectId(user_id)})
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan",
        )

def verify_email_token(token: str):
    try:
        payload = decode_access_token(token)
        email = payload.get("sub")
        if not email or payload.get("type") != "short":
            raise ValueError()
    except Exception:
        raise HTTPException(status_code=400, detail="Token tidak valid atau kedaluwarsa")
        
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    users_collection.update_one({"_id": user["_id"]}, {"$set": {"is_verified": True}})

def process_forgot_password(email: str):
    user = get_user_by_email(email.lower())
    if not user:
        # Don't reveal if user exists or not, just return
        return
        
    token = create_short_lived_token(user["email"], minutes=60)
    send_reset_password_email(user["email"], token)

def process_reset_password(token: str, new_password: str):
    try:
        payload = decode_access_token(token)
        email = payload.get("sub")
        if not email or payload.get("type") != "short":
            raise ValueError()
    except Exception:
        raise HTTPException(status_code=400, detail="Token tidak valid atau kedaluwarsa")
        
    user = get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    users_collection.update_one(
        {"_id": user["_id"]}, 
        {"$set": {"hashed_password": hash_password(new_password)}}
    )
    send_password_changed_email(email)
