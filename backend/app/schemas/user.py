from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    gender: str | None = None
    date_of_birth: str | None = None
    face_image: str | None = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class UserUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=100)
    email: EmailStr | None = None
    gender: str | None = None
    date_of_birth: str | None = None
    password: str | None = Field(default=None, min_length=6, max_length=128)
    confirm_password: str | None = Field(default=None, min_length=6, max_length=128)
    theme: str | None = None


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    email: EmailStr
    provider: str = "local"
    gender: str = "unknown"
    date_of_birth: str | None = None
    theme: str = "light"
    photo_url: str | None = None
    face_image: str | None = None
    is_verified: bool = False


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class MessageResponse(BaseModel):
    message: str


class GoogleLoginRequest(BaseModel):
    id_token: str = Field(min_length=10)
