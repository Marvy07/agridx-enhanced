from typing import Optional
from fastapi import APIRouter, Depends, File, Form, UploadFile
from app.auth import verify_firebase_token
from app.models import DetectionResult

router = APIRouter()

_PLANT_MOCK = DetectionResult(
    disease_name="Mock Disease (model not yet deployed)",
    confidence=0.0,
    severity="unknown",
    description="Plant detection model not yet deployed. This is a scaffold response.",
    treatments=[],
    image_urls=[],
    model_version="scaffold-0.1",
)

_ANIMAL_MOCK = DetectionResult(
    disease_name="Mock Disease (model not yet deployed)",
    confidence=0.0,
    severity="unknown",
    description="Animal detection model not yet deployed. This is a scaffold response.",
    treatments=[],
    image_urls=[],
    model_version="scaffold-0.1",
)


@router.post("/api/v1/detect/plant", response_model=DetectionResult)
async def detect_plant(
    image: Optional[UploadFile] = File(None),
    image_base64: Optional[str] = Form(None),
    _user: dict = Depends(verify_firebase_token),
) -> DetectionResult:
    return _PLANT_MOCK


@router.post("/api/v1/detect/animal", response_model=DetectionResult)
async def detect_animal(
    image: Optional[UploadFile] = File(None),
    species: Optional[str] = Form(None),
    _user: dict = Depends(verify_firebase_token),
) -> DetectionResult:
    return _ANIMAL_MOCK
