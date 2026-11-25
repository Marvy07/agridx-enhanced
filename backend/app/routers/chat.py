from fastapi import APIRouter, Depends
from app.auth import verify_firebase_token
from app.models import ChatRequest, ChatResponse

router = APIRouter()


@router.post("/api/v1/chat", response_model=ChatResponse)
async def chat(
    body: ChatRequest,
    _user: dict = Depends(verify_firebase_token),
) -> ChatResponse:
    return ChatResponse(
        reply="AI chat not yet wired to backend. Please use the app's direct Gemini integration for now.",
        sources=[],
    )
