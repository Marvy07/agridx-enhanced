import json
import os
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.routers import chat, crops, detection, health, payments, subscriptions, symptom_check

structlog.configure(
    processors=[
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer(),
    ]
)

log = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()

    # Sentry
    if settings.sentry_dsn:
        import sentry_sdk
        sentry_sdk.init(dsn=settings.sentry_dsn, environment=settings.environment)
        log.info("sentry_initialized")

    # Firebase Admin SDK
    firebase_initialized = False
    try:
        import firebase_admin
        from firebase_admin import credentials

        if settings.firebase_service_account_json:
            sa = json.loads(settings.firebase_service_account_json)
            cred = credentials.Certificate(sa)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
            log.info("firebase_initialized", source="service_account_json")
        else:
            firebase_admin.initialize_app()
            firebase_initialized = True
            log.info("firebase_initialized", source="application_default_credentials")
    except Exception as exc:
        log.warning("firebase_init_skipped", reason=str(exc))

    if firebase_initialized:
        from app.auth import set_firebase_available
        set_firebase_available(True)

    yield

    log.info("shutdown")


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="AgriDX Enhanced API",
        version="1.0.0",
        description="Disease detection and agricultural AI backend",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(health.router)
    app.include_router(detection.router)
    app.include_router(symptom_check.router)
    app.include_router(chat.router)
    app.include_router(crops.router)
    app.include_router(subscriptions.router)
    app.include_router(payments.router)

    return app


app = create_app()
