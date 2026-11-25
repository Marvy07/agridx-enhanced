# 🌱 AgriDx — AI-Powered Smart Agriculture & Plant Disease Diagnosis

AgriDx is an all-in-one smart farming application built with Flutter, TensorFlow Lite, and Gemini AI to assist farmers with instant crop disease detection, offline diagnostics, fertilizer calculation, weather forecasts, and community support.

---

## 🚀 Quick Setup Guide for Developers

### Prerequisites
- **Flutter SDK:** ^3.11.1 or higher (Channel stable)
- **Dart SDK:** Included with Flutter
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Java Development Kit (JDK):** Version 17 or higher

---

### Step-by-Step Installation

#### 1. Clone the repository
```bash
git clone https://github.com/Ndesoplacid/agridx-app.git
cd agridx-app
```

#### 2. Configure Environment Variables (`.env`)
The app requires a `.env` file in the project root for API keys (Gemini, Weather, Groq, News).
Copy the provided `.env.example` file:

- **Windows (Command Prompt / PowerShell):**
  ```powershell
  copy .env.example .env
  ```
- **macOS / Linux:**
  ```bash
  cp .env.example .env
  ```

> **Note:** Fill in your API keys in `.env` (or request the development `.env` file from the repository maintainer).

#### 3. Install Dependencies
```bash
flutter pub get
```

#### 4. Run the Application
Connect an Android device (via USB with USB Debugging enabled) or start an Android Emulator, then run:
```bash
flutter run
```

To build a release APK:
```bash
flutter build apk --release
```

---

## 🛠️ Architecture & Tech Stack

- **Framework:** Flutter (Mobile Android & iOS)
- **State Management:** Riverpod 2.x
- **Local Storage:** Hive & SQLite (Sqflite)
- **Backend & Auth:** Firebase (Auth, Cloud Firestore, Cloud Storage, Cloud Messaging)
- **AI & ML Engines:**
  - **On-Device:** TensorFlow Lite (`agridx_model.tflite`) for instant offline plant disease classification
  - **Cloud:** Google Generative AI (Gemini Vision) & Groq for comprehensive agricultural recommendations
- **APIs:** OpenWeatherMap API, NewsAPI
- **Speech & Audio:** Flutter TTS (Text-to-Speech)

---

## 📖 Documentation
- For full app features, user guide, and offline capabilities, see [USER_MANUAL.md](USER_MANUAL.md).
