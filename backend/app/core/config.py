from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    MONGO_URI: str = (
        "mongodb+srv://mindtrack:mindtrack123@cluster0.68pvtdq.mongodb.net/"
        "?appName=Cluster0"
    )
    MONGODB_DATABASE: str = "mindtrack"
    APP_TITLE: str = "MindTrack API"
    APP_VERSION: str = "1.0.0"

    JWT_SECRET: str = "mindtrack-dev-secret-ganti-di-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 hari

    # Web Client ID dari Google Cloud Console (OAuth 2.0)
    GOOGLE_CLIENT_ID: str = ""
    # Client ID tambahan (Android/iOS), pisahkan dengan koma
    GOOGLE_CLIENT_IDS: str = ""

    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_EMAIL: str = "mindtrack26@gmail.com"
    SMTP_PASSWORD: str = ""
    
    # URL backend untuk reset password
    APP_URL: str = "https://swan-compactor-revenge.ngrok-free.dev"

    # Groq settings
    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "llama-3.3-70b-versatile"

    @property
    def google_audiences(self) -> list[str]:
        audiences: list[str] = []
        if self.GOOGLE_CLIENT_ID.strip():
            audiences.append(self.GOOGLE_CLIENT_ID.strip())
        if self.GOOGLE_CLIENT_IDS.strip():
            audiences.extend(
                client_id.strip()
                for client_id in self.GOOGLE_CLIENT_IDS.split(",")
                if client_id.strip()
            )
        return audiences


settings = Settings()
