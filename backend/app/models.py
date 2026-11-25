from typing import Optional, Literal
from pydantic import BaseModel


class DetectionRequest(BaseModel):
    image_base64: str
    species: Optional[str] = None


class DetectionResult(BaseModel):
    disease_name: str
    confidence: float
    severity: str
    description: str
    treatments: list[str]
    image_urls: list[str]
    model_version: str


class SymptomCheckRequest(BaseModel):
    symptoms: str
    subject_type: Literal["plant", "animal"]
    species: Optional[str] = None


class SymptomCheckResult(BaseModel):
    differential: list[dict]
    recommendation: str


class ChatRequest(BaseModel):
    message: str
    history: list[dict] = []


class ChatResponse(BaseModel):
    reply: str
    sources: list[str] = []


class HealthResponse(BaseModel):
    status: str
    version: str
    environment: str
    firebase_initialized: bool
    vertex_ai_available: bool
