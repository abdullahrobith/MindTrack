from fastapi import APIRouter, Depends, status, Form
from fastapi.responses import HTMLResponse

from app.core.security import create_access_token
from app.dependencies.auth import get_current_user
from app.schemas.user import (
    GoogleLoginRequest,
    MessageResponse,
    TokenResponse,
    UserCreate,
    UserLogin,
    UserResponse,
    UserUpdate,
    ForgotPasswordRequest,
)
from app.services.user_service import (
    authenticate_user,
    create_user,
    login_or_register_with_google,
    update_user,
    user_to_response,
    verify_email_token,
    process_forgot_password,
    process_reset_password,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post(
    "/register",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Daftar akun baru",
)
def register(data: UserCreate):
    create_user(data)
    return MessageResponse(message="Registrasi berhasil")


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Login dan dapatkan JWT token",
)
def login(data: UserLogin):
    user = authenticate_user(data.email, data.password)
    token = create_access_token(user["email"])
    return TokenResponse(access_token=token)


@router.post(
    "/google",
    response_model=TokenResponse,
    summary="Login / register via Google ID token",
)
def google_login(data: GoogleLoginRequest):
    user = login_or_register_with_google(data.id_token)
    token = create_access_token(user["email"])
    return TokenResponse(access_token=token)


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Profil user yang sedang login",
)
def me(current_user: dict = Depends(get_current_user)):
    return user_to_response(current_user)


@router.put(
    "/profile",
    response_model=UserResponse,
    summary="Update profil user yang sedang login",
)
def update_profile(
    data: UserUpdate,
    current_user: dict = Depends(get_current_user),
):
    return update_user(str(current_user["_id"]), data)

@router.get("/verify-email", response_class=HTMLResponse)
def verify_email(token: str):
    try:
        verify_email_token(token)
        return """
        <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
                <h2 style="color: #28A745;">Verifikasi Berhasil!</h2>
                <p>Email Anda telah berhasil diverifikasi. Anda sekarang dapat login ke aplikasi MindTrack.</p>
            </body>
        </html>
        """
    except Exception as e:
        return f"""
        <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
                <h2 style="color: #DC3545;">Verifikasi Gagal</h2>
                <p>{str(e)}</p>
            </body>
        </html>
        """

@router.post("/forgot-password", response_model=MessageResponse)
def forgot_password(data: ForgotPasswordRequest):
    process_forgot_password(data.email)
    return MessageResponse(message="Jika email terdaftar, link reset password telah dikirim.")

@router.get("/reset-password", response_class=HTMLResponse)
def reset_password_form(token: str):
    return f"""
    <html>
        <body style="font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px;">
            <h2 style="text-align: center; color: #333;">Reset Password MindTrack</h2>
            <form action="/auth/reset-password" method="post" style="display: flex; flex-direction: column; gap: 15px;">
                <input type="hidden" name="token" value="{token}">
                <div>
                    <label style="display: block; margin-bottom: 5px;">Password Baru:</label>
                    <input type="password" name="new_password" required minlength="6" style="width: 100%; padding: 8px; box-sizing: border-box;">
                </div>
                <button type="submit" style="padding: 10px; background-color: #007BFF; color: white; border: none; border-radius: 5px; cursor: pointer;">
                    Ubah Password
                </button>
            </form>
        </body>
    </html>
    """

@router.post("/reset-password", response_class=HTMLResponse)
def submit_reset_password(token: str = Form(...), new_password: str = Form(...)):
    try:
        process_reset_password(token, new_password)
        return """
        <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
                <h2 style="color: #28A745;">Password Berhasil Diubah!</h2>
                <p>Password Anda telah diperbarui. Silakan login ke aplikasi MindTrack dengan password baru Anda.</p>
            </body>
        </html>
        """
    except Exception as e:
        return f"""
        <html>
            <body style="font-family: Arial, sans-serif; text-align: center; padding: 50px;">
                <h2 style="color: #DC3545;">Reset Password Gagal</h2>
                <p>{str(e)}</p>
                <a href="javascript:history.back()">Kembali</a>
            </body>
        </html>
        """
