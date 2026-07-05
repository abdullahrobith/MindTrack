from fastapi import APIRouter, Depends, status

from app.dependencies.auth import get_current_user
from app.schemas.user import MessageResponse, TokenResponse
from app.services.face_service import register_face, verify_face
from pydantic import BaseModel, Field


class FaceImageRequest(BaseModel):
    image: str = Field(
        min_length=100,
        description="Base64 encoded image (bisa dengan atau tanpa prefix data:image/...)",
    )


router = APIRouter(prefix="/auth", tags=["Face Recognition"])


@router.post(
    "/register-face",
    response_model=MessageResponse,
    status_code=status.HTTP_200_OK,
    summary="Daftarkan wajah user yang sedang login",
)
def register_user_face(
    data: FaceImageRequest,
    current_user: dict = Depends(get_current_user),
):
    return register_face(str(current_user["_id"]), data.image)


@router.post(
    "/face-login",
    response_model=TokenResponse,
    summary="Login menggunakan face recognition",
)
def login_with_face(data: FaceImageRequest):
    result = verify_face(data.image)
    return TokenResponse(access_token=result["access_token"])
