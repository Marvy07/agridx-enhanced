import structlog
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.config import get_settings

log = structlog.get_logger()
security = HTTPBearer(auto_error=False)

_firebase_available = False


def set_firebase_available(value: bool) -> None:
    global _firebase_available
    _firebase_available = value


async def verify_firebase_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    settings = get_settings()

    # DEV_MODE=true: skip real auth entirely, return mock user
    if settings.dev_mode or not _firebase_available:
        log.warning("auth_bypassed", mode="dev_mock", dev_mode=settings.dev_mode)
        return {"uid": "dev-user", "email": "dev@agridx.app", "name": "Dev User"}

    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        import firebase_admin.auth as fb_auth
        decoded = fb_auth.verify_id_token(credentials.credentials)
        return decoded
    except Exception as exc:
        log.warning("token_verification_failed", error=str(exc))
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
