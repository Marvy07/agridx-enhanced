from fastapi import APIRouter, Depends
from app.auth import verify_firebase_token

router = APIRouter()


@router.post("/api/v1/payments/initialize")
async def initialize_payment(_user: dict = Depends(verify_firebase_token)) -> dict:
    # Phase 1: wire Paystack / Stripe here
    return {"status": "not_implemented", "message": "Payment processing coming in Phase 1"}
