# AgriDX Enhanced — Local Development Setup

**Everything works locally without Firebase, GCP, or payment accounts.**

---

## Prerequisites

- Flutter 3.x (run `flutter --version` to confirm)
- Python 3.12+ (run `python3 --version` to confirm)
- An Android emulator/device or iOS simulator (for Flutter mobile)

---

## 1. Clone the repo

```bash
git clone https://github.com/Marvy07/agridx-enhanced.git
cd agridx-enhanced
```

---

## 2. Flutter App

```bash
# Install Flutter dependencies
flutter pub get

# Copy and configure environment
cp .env.example .env
# Optional: fill in GEMINI_API_KEY and OPENWEATHER_API_KEY for AI chat + weather
# Leave API_BASE_URL=http://localhost:8000 to point at the local backend

# Run on device/emulator
flutter run

# Or build a debug APK
flutter build apk --debug
```

**What works without any API keys:**
- Auth screens (login/register UI)
- TFLite offline plant detection (uses bundled model)
- Crop library
- Community forum
- All navigation

**What needs keys (optional):**
- `GEMINI_API_KEY` — AI chat and symptom checker
- `OPENWEATHER_API_KEY` — weather widget
- `NEWS_API_KEY` — news feed

---

## 3. Backend API

```bash
cd backend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file (all defaults work for local dev)
cp .env.example .env
# DEV_MODE=true is set by default — no Firebase or GCP needed

# Start the server
uvicorn main:app --reload --port 8000
```

**Verify it's running:**
```bash
curl http://localhost:8000/health
# Expected: {"status":"ok","environment":"development","firebase_initialized":false,...}
```

**All endpoints are live and return scaffold responses:**

| Endpoint | Method | Notes |
|---|---|---|
| `/health` | GET | Returns server status |
| `/api/v1/detect/plant` | POST | Returns mock detection result |
| `/api/v1/detect/animal` | POST | Returns mock detection result |
| `/api/v1/symptom-check` | POST | Returns mock differential |
| `/api/v1/chat` | POST | Returns placeholder message |
| `/api/v1/crops` | GET | Returns empty list |
| `/api/v1/subscriptions` | GET | Returns `not_implemented` stub |
| `/api/v1/payments/initialize` | POST | Returns `not_implemented` stub |

**Interactive API docs:** http://localhost:8000/docs

---

## 4. DEV_MODE explained

`DEV_MODE=true` (the default in `.env.example`) bypasses Firebase token verification. All authenticated endpoints accept requests without a token and return a mock user `dev@agridx.app`.

To test with real Firebase auth, set:
```
DEV_MODE=false
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

---

## 5. What's not wired yet (Phase 1)

| Feature | Status | Needs |
|---|---|---|
| Firebase Auth (backend token verification) | Dormant — mock in dev | Firebase project + service account |
| Plant/animal ML detection | Mock response | Vertex AI endpoints + trained models |
| Subscription management | `not_implemented` stub | RevenueCat + Paystack/Stripe accounts |
| Payment processing | `not_implemented` stub | Paystack/Stripe accounts |
| Cloud Run deployment | Workflow in `_future/` | GCP project + service account |
| Cloudinary image CDN | Not wired | Cloudinary account |

---

## 6. Running tests

```bash
# Flutter tests
flutter test

# Backend tests
cd backend
source .venv/bin/activate
pytest tests/ -v
```

---

## 7. Project structure

```
agridx-enhanced/
├── lib/                    # Flutter app source
│   ├── core/router.dart    # go_router navigation
│   ├── features/           # Feature modules
│   │   ├── detection/      # Plant & animal detection screens
│   │   ├── subscription/   # Paywall screens (stubbed)
│   │   └── animals/        # Animal care guides
│   └── shared/services/api_service.dart  # Backend HTTP client
├── backend/                # FastAPI backend
│   ├── .venv/              # Python virtual env (gitignored)
│   ├── app/                # App modules
│   └── main.py             # Entry point
├── firestore/              # Firestore schema + security rules
├── _future/                # Dormant infra (Cloud Run CI, GCP setup)
└── .github/workflows/
    └── flutter-ci.yml      # CI: lint + test + build on push
```
