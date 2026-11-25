# AgriDX Enhanced

An AI-powered agricultural and veterinary intelligence platform for African farmers, smallholders, and field veterinarians.

**Built on:** [agridx-app](https://github.com/Ndesoplacid/agridx-app) by Placid Ndeso  
**Extended by:** Marvellous  
**Status:** Phase 0 — Scaffolding

---

## Stack

| Layer | Technology |
|---|---|
| Mobile + Web | Flutter 3.x (iOS, Android, PWA) |
| State | Riverpod 2.x |
| Navigation | go_router |
| Backend API | FastAPI (Python 3.12) on Cloud Run |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Cloud Storage |
| ML Serving | Vertex AI (EfficientNetV2-B4 + YOLOv8) |
| Mobile ML | TFLite (offline fallback) |
| Payments | Paystack + Stripe via RevenueCat |
| Image CDN | Cloudinary / Imgix |
| CI/CD | GitHub Actions |

---

## Project Structure

```
agridx-enhanced/
├── lib/                    # Flutter app
│   ├── core/               # Router, theme, constants, providers
│   ├── features/           # Feature modules
│   │   ├── auth/           # Login, register
│   │   ├── detection/      # Plant & animal disease detection
│   │   ├── library/        # Crop library
│   │   ├── animals/        # Animal care guides
│   │   ├── subscription/   # Paywall, subscription management
│   │   ├── community/      # Forum
│   │   ├── chat/           # AI assistant
│   │   ├── weather/        # Weather widget
│   │   └── profile/        # User profile
│   └── shared/             # Models, services, widgets
├── backend/                # FastAPI backend
│   ├── app/
│   │   ├── routers/        # API route handlers
│   │   ├── auth.py         # Firebase token verification
│   │   ├── models.py       # Pydantic request/response models
│   │   └── config.py       # Settings from environment
│   ├── scripts/            # Firestore seed scripts
│   ├── tests/              # pytest test suite
│   ├── Dockerfile          # Cloud Run container
│   └── requirements.txt
├── firestore/              # Firestore schema + security rules
│   ├── schema.md           # Collection schemas documented
│   └── firestore.rules     # Firestore security rules
└── .github/workflows/      # CI/CD pipelines
    ├── flutter-ci.yml      # Lint + test + build on push
    └── deploy-cloud-run.yml # Deploy backend on main push
```

---

## Getting Started

### Flutter App

```bash
# Install dependencies
flutter pub get

# Copy env file
cp .env.example .env
# Fill in your API keys

# Run on device/emulator
flutter run

# Build debug APK
flutter build apk --debug
```

### Backend API

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Fill in credentials

# Run locally
uvicorn main:app --reload --port 8000

# Health check
curl http://localhost:8000/health
```

---

## Environment Variables

### Flutter (.env)
| Key | Description |
|---|---|
| GEMINI_API_KEY | Google Gemini API key |
| OPENWEATHER_API_KEY | OpenWeatherMap API key |
| GROQ_API_KEY | Groq API key (fallback LLM) |
| NEWS_API_KEY | NewsAPI key |
| BACKEND_URL | FastAPI backend URL (default: http://localhost:8000) |

### Backend (backend/.env)
| Key | Description |
|---|---|
| FIREBASE_PROJECT_ID | Firebase project ID |
| FIREBASE_SERVICE_ACCOUNT_JSON | Service account JSON (for Cloud Run) |
| GOOGLE_CLOUD_PROJECT | GCP project ID |
| VERTEX_AI_LOCATION | Vertex AI region (default: us-central1) |
| PLANT_MODEL_ENDPOINT | Vertex AI plant model endpoint ID |
| ANIMAL_MODEL_ENDPOINT | Vertex AI animal model endpoint ID |
| GEMINI_API_KEY | Gemini API key |
| SENTRY_DSN | Sentry error tracking DSN |

---

## Required Accounts (for full deployment)

- [ ] GCP project (Cloud Run, Vertex AI, Secret Manager)
- [ ] Firebase project (Blaze plan)
- [ ] Paystack business account (African payments)
- [ ] Stripe account (global payments)
- [ ] RevenueCat account (subscription management)
- [ ] Cloudinary or Imgix account (image CDN)

---

## MVP Features

- Plant disease detection (200+ diseases, 50+ crops)
- Animal disease detection (cattle, goats, poultry, pigs, dogs, cats)
- Symptom-based differential diagnosis
- Crop and animal care library with real photos
- Subscription tiers (Free / Premium / Pro)
- Offline mode (TFLite on-device detection)
- Flutter Web PWA + mobile apps

---

## Attribution

Original Flutter app by [Placid Ndeso](https://github.com/Ndesoplacid/agridx-app) — licensed under original terms.  
Enhanced version by Marvellous.
