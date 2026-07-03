from google.auth.transport import requests as google_requests
from google.oauth2 import id_token

from app.core.config import settings


def verify_google_id_token(token: str) -> dict:
    audiences = settings.google_audiences
    if not audiences:
        raise ValueError("GOOGLE_CLIENT_ID belum dikonfigurasi di backend")

    request = google_requests.Request()

    # Pass web client ID sebagai audience utama saat verifikasi
    # Google akan tetap menerima token dari Android client ID
    try:
        idinfo = id_token.verify_oauth2_token(token, request, audience=audiences[0])
    except ValueError:
        # Coba audience lain jika ada (misal Android Client ID)
        idinfo = None
        for aud in audiences[1:]:
            try:
                idinfo = id_token.verify_oauth2_token(token, request, audience=aud)
                break
            except ValueError:
                continue
        if idinfo is None:
            raise ValueError("Google token tidak valid untuk semua audience yang dikonfigurasi")

    # aud bisa berupa string (satu audience) atau list (multiple audiences)
    token_aud = idinfo.get("aud")
    if isinstance(token_aud, list):
        valid = any(a in audiences for a in token_aud)
    else:
        valid = token_aud in audiences

    if not valid:
        raise ValueError("Google token audience tidak valid")

    issuer = idinfo.get("iss", "")
    if issuer not in {"accounts.google.com", "https://accounts.google.com"}:
        raise ValueError("Google token issuer tidak valid")

    if not idinfo.get("email"):
        raise ValueError("Email tidak tersedia dari Google")

    return idinfo
