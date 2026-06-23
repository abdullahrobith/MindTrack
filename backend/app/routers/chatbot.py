from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import requests
from app.core.config import settings

router = APIRouter(prefix="/chatbot", tags=["Chatbot"])

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    messages: list[ChatMessage]

@router.post("/")
async def chat_with_bot(request: ChatRequest):
    if not settings.GROQ_API_KEY:
        raise HTTPException(status_code=500, detail="GROQ_API_KEY is not configured")
        
    headers = {
        "Authorization": f"Bearer {settings.GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Prepend a system message for context
    messages_payload = [
        {
            "role": "system", 
            "content": "Kamu adalah MindTrack, asisten virtual kesehatan mental yang empati, ramah, dan solutif. Gunakan bahasa Indonesia yang baik, santai namun tetap sopan. Berikan dukungan emosional, tetapi ingat untuk selalu menyarankan bantuan profesional jika ada indikasi masalah kesehatan mental yang serius."
        }
    ]
    
    for msg in request.messages:
        messages_payload.append({
            "role": msg.role,
            "content": msg.content
        })

    payload = {
        "model": settings.GROQ_MODEL,
        "messages": messages_payload,
        "temperature": 0.7,
        "max_tokens": 1024
    }

    try:
        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers=headers,
            json=payload,
            timeout=30
        )
        response.raise_for_status()
        data = response.json()
        
        reply = data.get("choices", [])[0].get("message", {}).get("content", "")
        return {"reply": reply}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
