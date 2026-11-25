from functools import lru_cache
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    dev_mode: bool = True
    environment: str = "development"
    api_base_url: str = "http://localhost:8000"

    firebase_project_id: str = ""
    firebase_service_account_json: str = ""

    # GCP / Vertex AI — commented out until Phase 1
    # google_cloud_project: str = ""
    # vertex_ai_location: str = "us-central1"
    # plant_model_endpoint: str = ""
    # animal_model_endpoint: str = ""

    gemini_api_key: str = ""
    groq_api_key: str = ""
    sentry_dsn: str = ""
    cors_origins: list[str] = ["*"]

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "extra": "ignore",
    }


@lru_cache
def get_settings() -> Settings:
    return Settings()
