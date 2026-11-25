from fastapi import APIRouter, HTTPException

router = APIRouter()


@router.get("/api/v1/crops")
async def list_crops() -> dict:
    return {"crops": [], "note": "Crop library not yet seeded. Run backend/scripts/seed_firestore.py."}


@router.get("/api/v1/crops/{crop_id}")
async def get_crop(crop_id: str) -> dict:
    raise HTTPException(status_code=404, detail="Crop library not yet seeded")
