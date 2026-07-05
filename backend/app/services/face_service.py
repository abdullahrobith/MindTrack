import base64
import os
import tempfile
import time
from datetime import datetime, timezone

from bson import ObjectId
from deepface import DeepFace
from fastapi import HTTPException, status

from app.core.security import create_access_token
from app.db.mongodb import db

users_collection = db["users"]

FACE_THRESHOLD = 0.30
MODEL_NAME = "Facenet512"
DETECTOR = "opencv"


def _decode_base64_to_file(image_base64: str) -> str:
    temp = tempfile.NamedTemporaryFile(delete=False, suffix=".jpg")
    try:
        if "," in image_base64:
            image_base64 = image_base64.split(",")[1]
        image_bytes = base64.b64decode(image_base64)
        temp.write(image_bytes)
        temp_path = temp.name
        return temp_path
    except Exception:
        temp.close()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Gagal decode gambar. Pastikan format base64 valid.",
        )


def register_face(user_id: str, image_base64: str) -> dict:
    if not ObjectId.is_valid(user_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ID user tidak valid",
        )

    user = users_collection.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User tidak ditemukan",
        )

    temp_path = None
    try:
        temp_path = _decode_base64_to_file(image_base64)

        DeepFace.represent(
            img_path=temp_path,
            model_name=MODEL_NAME,
            detector_backend=DETECTOR,
            enforce_detection=True,
        )
    except ValueError as e:
        if "Face could not be detected" in str(e):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Tidak ada wajah terdeteksi di gambar. Silakan coba lagi.",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal memproses gambar: {str(e)}",
        )
    finally:
        if temp_path and os.path.exists(temp_path):
            os.remove(temp_path)

    if "," in image_base64:
        image_base64 = image_base64.split(",")[1]

    users_collection.update_one(
        {"_id": ObjectId(user_id)},
        {
            "$set": {
                "face_image": image_base64,
                "face_updated_at": datetime.now(timezone.utc),
            }
        },
    )

    return {"message": "Wajah berhasil didaftarkan"}


def verify_face(image_base64: str) -> dict:
    input_path = None
    try:
        input_path = _decode_base64_to_file(image_base64)

        DeepFace.represent(
            img_path=input_path,
            model_name=MODEL_NAME,
            detector_backend=DETECTOR,
            enforce_detection=True,
        )
    except ValueError as e:
        if "Face could not be detected" in str(e):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Tidak ada wajah terdeteksi",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e),
        )

    users_with_faces = list(
        users_collection.find(
            {"face_image": {"$exists": True, "$ne": None, "$ne": ""}}
        )
    )

    if not users_with_faces:
        if input_path and os.path.exists(input_path):
            os.remove(input_path)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belum ada wajah terdaftar di database",
        )

    best_match = None
    best_distance = 999.0

    for user in users_with_faces:
        db_path = None
        try:
            db_path = _decode_base64_to_file(user["face_image"])

            result = DeepFace.verify(
                img1_path=input_path,
                img2_path=db_path,
                model_name=MODEL_NAME,
                detector_backend=DETECTOR,
                enforce_detection=False,
            )

            distance = result["distance"]
            if distance < best_distance:
                best_distance = distance
                best_match = user

        except Exception:
            continue
        finally:
            if db_path and os.path.exists(db_path):
                os.remove(db_path)

    if input_path and os.path.exists(input_path):
        os.remove(input_path)

    if best_match and best_distance < FACE_THRESHOLD:
        token = create_access_token(best_match["email"])
        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "id": str(best_match["_id"]),
                "name": best_match.get("name", ""),
                "email": best_match.get("email", ""),
            },
        }

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Wajah belum terdaftar",
    )
