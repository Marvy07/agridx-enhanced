from fastapi import APIRouter, Depends
from app.auth import verify_firebase_token
from app.models import SymptomCheckRequest, SymptomCheckResult

router = APIRouter()


@router.post("/api/v1/symptom-check", response_model=SymptomCheckResult)
async def symptom_check(
    body: SymptomCheckRequest,
    _user: dict = Depends(verify_firebase_token),
) -> SymptomCheckResult:
    return SymptomCheckResult(
        differential=[
            {
                "disease": "Scaffold Placeholder",
                "probability": 0.0,
                "description": "Symptom check model not yet deployed. This is a scaffold response.",
            }
        ],
        recommendation="Please consult a local agronomist until the AI model is deployed.",
    )
