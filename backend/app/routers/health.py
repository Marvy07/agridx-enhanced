from fastapi import APIRouter
from app.models import HealthResponse
from app.config import get_settings

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    settings = get_settings()

    try:
        import firebase_admin
        firebase_initialized = firebase_admin._DEFAULT_APP_NAME in firebase_admin._apps
    except Exception:
        firebase_initialized = False

    return HealthResponse(
        status="ok",
        version="1.0.0",
        environment=settings.environment,
        firebase_initialized=firebase_initialized,
        vertex_ai_available=False,  # Phase 1: set True when Vertex AI endpoints are configured
    )
