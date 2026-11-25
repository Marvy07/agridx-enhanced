from fastapi import APIRouter, Depends, Request
from app.auth import verify_firebase_token

router = APIRouter()


@router.get("/api/v1/subscriptions")
async def get_subscription(user: dict = Depends(verify_firebase_token)) -> dict:
    # Phase 1: read from Firestore subscriptions/{uid} here
    return {
        "status": "not_implemented",
        "tier": "free",
        "valid_until": None,
        "detections_today": 0,
        "detections_limit": 5,
        "user_id": user.get("uid"),
        "message": "Subscription management coming in Phase 1",
    }


@router.post("/api/v1/subscriptions/webhook/paystack")
async def paystack_webhook(request: Request) -> dict:
    # Phase 1: verify HMAC signature and update Firestore + RevenueCat
    return {"status": "not_implemented", "message": "Paystack webhook bridge coming in Phase 1"}


@router.post("/api/v1/subscriptions/webhook/stripe")
async def stripe_webhook(request: Request) -> dict:
    # Phase 1: verify Stripe signature and update Firestore
    return {"status": "not_implemented", "message": "Stripe webhook coming in Phase 1"}
