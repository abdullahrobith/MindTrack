from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.routers import articles, auth, search, trends, users, assessment, chatbot

app = FastAPI(
    title=settings.APP_TITLE,
    description=(
        "API MindTrack — Mental Health App\n\n"
        "**Cara pakai Swagger:**\n"
        "1. Login via `POST /auth/login` atau `POST /auth/google`\n"
        "2. Copy `access_token` dari response\n"
        "3. Klik **Authorize** → paste token → **Authorize**"
    ),
    version=settings.APP_VERSION,
    swagger_ui_parameters={"persistAuthorization": True},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(articles.router)
app.include_router(trends.router)
app.include_router(search.router)
app.include_router(assessment.router)
app.include_router(chatbot.router)


@app.get("/", tags=["Root"])
def root():
    return {
        "message": "MindTrack API Running",
        "docs": "/docs",
        "redoc": "/redoc",
    }
