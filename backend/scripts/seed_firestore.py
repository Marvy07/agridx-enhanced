#!/usr/bin/env python3
"""
Seed Firestore with initial schema template documents.

Usage:
    python seed_firestore.py                   # seed all collections
    python seed_firestore.py --dry-run         # print without writing
    python seed_firestore.py --collection users  # seed one collection
"""

import argparse
import json
import sys
from datetime import datetime, timezone

NOW = datetime.now(timezone.utc).isoformat()

SCHEMA: dict[str, tuple[str, dict]] = {
    "users": (
        "example_user_uid",
        {
            "uid": "example_user_uid",
            "email": "farmer@example.com",
            "displayName": "Example Farmer",
            "farmType": "mixed",
            "crops": ["maize", "cassava"],
            "animals": ["cattle", "goat"],
            "region": "West Africa",
            "subscriptionTier": "free",
            "detectionsToday": 0,
            "createdAt": NOW,
            "updatedAt": NOW,
        },
    ),
    "crops": (
        "maize_001",
        {
            "id": "maize_001",
            "name": "Maize",
            "scientificName": "Zea mays",
            "description": "Staple cereal grain widely grown in Africa.",
            "imageUrl": "",
            "commonDiseases": ["Northern Leaf Blight", "Maize Streak Virus"],
            "growingRegions": ["Sub-Saharan Africa", "South Asia"],
            "plantingGuide": "Plant at start of rainy season, 60–75 cm row spacing.",
            "harvestGuide": "Harvest 90–120 days after planting when husks turn brown.",
            "updatedAt": NOW,
        },
    ),
    "animals": (
        "cattle_001",
        {
            "id": "cattle_001",
            "name": "Cattle",
            "species": "Bos taurus",
            "description": "Domesticated bovine raised for milk and meat.",
            "imageUrl": "",
            "commonDiseases": ["Foot-and-Mouth Disease", "Brucellosis", "East Coast Fever"],
            "careGuide": "Provide clean water, balanced feed, and routine vaccinations.",
            "breedInfo": "Common breeds: Zebu, Ankole, Holstein.",
            "updatedAt": NOW,
        },
    ),
    "diseases": (
        "northern_leaf_blight_001",
        {
            "id": "northern_leaf_blight_001",
            "name": "Northern Leaf Blight",
            "type": "plant",
            "affectedSpecies": ["Zea mays"],
            "symptoms": ["Grey-green water-soaked lesions", "Cigar-shaped lesions on leaves"],
            "description": "Fungal disease caused by Exserohilum turcicum.",
            "treatment": "Apply fungicides; use resistant varieties.",
            "severity": "medium",
            "imageUrls": [],
            "modelClass": "northern_leaf_blight",
            "updatedAt": NOW,
        },
    ),
    "detections": (
        "example_detection_001",
        {
            "id": "example_detection_001",
            "userId": "example_user_uid",
            "type": "plant",
            "diseaseName": "Northern Leaf Blight",
            "confidence": 0.92,
            "severity": "medium",
            "imageUrl": "",
            "createdAt": NOW,
        },
    ),
    "subscriptions": (
        "example_user_uid",
        {
            "userId": "example_user_uid",
            "tier": "free",
            "validUntil": None,
            "paystackCustomerId": "",
            "stripeCustomerId": "",
            "revenuecatUserId": "",
            "updatedAt": NOW,
        },
    ),
    "alerts": (
        "example_alert_001",
        {
            "id": "example_alert_001",
            "userId": "example_user_uid",
            "cropOrAnimal": "maize",
            "region": "West Africa",
            "diseaseId": "northern_leaf_blight_001",
            "sentAt": NOW,
            "channel": "push",
        },
    ),
}


def seed(dry_run: bool = False, collection: str | None = None) -> None:
    targets = {collection: SCHEMA[collection]} if collection else SCHEMA

    if not dry_run:
        import firebase_admin
        from firebase_admin import credentials, firestore

        if not firebase_admin._apps:
            firebase_admin.initialize_app()
        db = firestore.client()

    for col, (doc_id, data) in targets.items():
        print(f"[{'DRY RUN' if dry_run else 'WRITE'}] {col}/{doc_id}")
        if dry_run:
            print(json.dumps(data, indent=2, default=str))
            print()
        else:
            db.collection(col).document(doc_id).set(data)
            print(f"  OK")

    print(f"\nDone. {len(targets)} collection(s) seeded.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Seed Firestore schema templates")
    parser.add_argument("--dry-run", action="store_true", help="Print without writing")
    parser.add_argument("--collection", choices=list(SCHEMA.keys()), help="Seed one collection only")
    args = parser.parse_args()

    if args.collection and args.collection not in SCHEMA:
        print(f"Unknown collection: {args.collection}. Valid: {', '.join(SCHEMA)}", file=sys.stderr)
        sys.exit(1)

    seed(dry_run=args.dry_run, collection=args.collection)


if __name__ == "__main__":
    main()
