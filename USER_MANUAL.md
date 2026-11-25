# 🌱 AgriDx — Complete User Manual & Guide
**Version:** 1.0.0 | **Platform:** Android 8.0+ | **Release:** November 2026

---

## 📖 Table of Contents
1. [Introduction to AgriDx](#1-introduction-to-agridx)
2. [Installation & Permissions](#2-installation--permissions)
3. [Getting Started & Authentication](#3-getting-started--authentication)
4. [Core Feature: AI Crop Disease Scanner](#4-core-feature-ai-crop-disease-scanner)
5. [Understanding Diagnosis Results & Remedies](#5-understanding-diagnosis-results--remedies)
6. [Farming Tools & Calculators](#6-farming-tools--calculators)
7. [Crop Library & Crop Calendar](#7-crop-library--crop-calendar)
8. [Weather & Agricultural Advisory](#8-weather--agricultural-advisory)
9. [AI Agronomist Chatbot](#9-ai-agronomist-chatbot)
10. [Farmer Community Forum](#10-farmer-community-forum)
11. [Agricultural News & Updates](#11-agricultural-news--updates)
12. [User Profile, History & Settings](#12-user-profile-history--settings)
13. [Offline Mode Capabilities](#13-offline-mode-capabilities)
14. [Troubleshooting & Frequently Asked Questions](#14-troubleshooting--frequently-asked-questions)

---

## 1. Introduction to AgriDx

**AgriDx** is an all-in-one smart agriculture and plant disease diagnosis application designed to empower smallholder farmers, agronomists, and garden enthusiasts with instant crop health insights, scientific farming tools, and community knowledge.

### Key Capabilities:
- **Instant AI Disease Detection:** Detects plant diseases and pests in seconds using deep learning computer vision (TensorFlow Lite) and Gemini AI.
- **Actionable Treatment Plans:** Provides step-by-step organic, chemical, and biological remedies.
- **Voice/Text-to-Speech:** Listens to diagnosis recommendations aloud in your preferred language.
- **Smart Fertilizer Calculator:** Computes exact N-P-K nutrient quantities according to your farm size and crop type.
- **Localized Weather & Spray Forecast:** Offers real-time climate data with actionable farming advisories (when to spray, irrigate, or harvest).
- **AI Agronomist Chat:** Answers 24/7 farming questions via an intelligent agronomy assistant.
- **Community Forum:** Enables farmers to ask questions, share field photos, and learn from peers.
- **Full Offline Support:** Runs AI diagnosis and accesses offline disease databases even when network connectivity is unavailable in remote fields.

---

## 2. Installation & Permissions

### 2.1 Installing the APK on Android
1. Download or copy `app-release.apk` onto your Android smartphone or tablet.
2. Open your device's **Files** or **Downloads** folder and tap on **`app-release.apk`**.
3. If Android prompts: *"For your security, your phone is not allowed to install unknown apps from this source"*:
   - Tap **Settings**.
   - Toggle **"Allow from this source"** to **ON**.
   - Press the Back button.
4. Tap **Install**, then tap **Open** once installation completes.

### 2.2 Permissions Explained
When you first launch AgriDx, the app may request the following permissions:
- 📷 **Camera:** Required to take photos of plant leaves and stems for disease diagnosis.
- 🖼️ **Storage / Media:** Required to upload existing crop photos from your gallery and store offline reports.
- 📍 **Location:** Required to fetch real-time local weather forecasts, humidity, and rainfall alerts for your specific farm.
- 🔔 **Notifications:** Required to receive weather hazard warnings, pest outbreak alerts, and community replies.

---

## 3. Getting Started & Authentication

### 3.1 Onboarding Walkthrough
When you open AgriDx for the first time, an interactive onboarding screen introduces the key features:
- AI Disease Detection
- Smart Farming Calculators
- Community & Weather Advisory

Tap **"Get Started"** to proceed to the login screen.

### 3.2 Account Options
- **Sign In with Email & Password:** Log in with your registered email and password.
- **Sign Up:** Create a new account using your name, email, and password.
- **Google Sign-In:** One-tap quick authentication using your Google account.
- **Continue as Guest:** Allows you to test the scanner, calculators, crop library, and weather without signing up immediately. *(Note: Posting in the community and saving cloud history requires an account).*

---

## 4. Core Feature: AI Crop Disease Scanner

The central feature of AgriDx is its high-accuracy AI leaf scanner.

```
       [ CAMERA / GALLERY ]
                │
                ▼
  [ ON-DEVICE TFLITE ENGINE ]  ◄── (Works 100% Offline)
                │
                ▼
   [ GEMINI / CLOUD AI ENGINE ] ◄── (When Online: In-depth analysis)
                │
                ▼
 [ DETAILED DIAGNOSIS & REMEDY REPORT ]
```

### Step-by-Step Scanning Guide:
1. Tap the prominent **Scan / Camera Button** on the Home screen.
2. Select your photo source:
   - **Take Photo (Camera):** Point your camera directly at the affected leaf.
   - **Upload from Gallery:** Select an existing clear photo of the infected crop.
3. **Photography Best Practices for Maximum Accuracy:**
   - 🎯 **Focus:** Ensure the disease symptoms (spots, mildew, discoloration, lesions) are sharp and in focus.
   - ☀️ **Lighting:** Capture photos in natural daylight. Avoid harsh shadows or extreme glare.
   - 🌿 **Framing:** Center the affected leaf so it occupies at least 60–70% of the screen.
   - 🚫 **Avoid Blurry Photos:** Hold the phone steady before snapping the shutter.
4. Tap **Diagnose** to begin analysis. The app processes the image and presents the complete report in 2–3 seconds.

---

## 5. Understanding Diagnosis Results & Remedies

The Diagnosis Result screen displays a comprehensive diagnostic breakdown:

### 1. Disease Identification & Confidence Score
- **Crop & Disease Name:** (e.g., *Tomato Early Blight*, *Maize Fall Armyworm*, *Healthy Plant*).
- **Confidence Level:** A percentage indicating how certain the AI model is (e.g., `96% Match`).

### 2. Audio Read-Out (Text-to-Speech)
- Tap the **Speaker / Listen Icon** (🔊) at the top right to have the diagnosis and treatment steps read aloud in your selected language.
- Great for hands-free listening while working in the field!

### 3. Comprehensive Breakdown Tabs:
- **Symptoms:** What signs to look for (leaf spots, yellow halos, wilting, curling).
- **Causes:** Environmental factors, fungal spores, insect vectors, or overwatering.
- **Organic Remedies:** Eco-friendly, chemical-free solutions (e.g., neem oil spray, copper fungicide, crop rotation, compost tea).
- **Chemical Treatments:** Recommended active ingredients, application dosage, and spray intervals when chemical intervention is necessary.
- **Preventive Measures:** Steps to prevent re-infection in subsequent planting cycles.

### 4. Saving & Sharing:
- Tap **Save to History** to archive the diagnosis with timestamp and photo for future reference.
- Tap **Share to Community** to ask experienced farmers for second opinions or feedback.

---

## 6. Farming Tools & Calculators

From the Home screen quick actions or Tools menu, access dedicated farming utilities:

### 6.1 Smart Fertilizer Calculator
Avoid fertilizer wastage and nutrient burns by calculating exact requirements:
1. Select your target **Crop** (e.g., Maize, Rice, Tomato, Cassava).
2. Enter your **Field Area** (in Hectares, Acres, or Square Meters).
3. Select the **Growth Stage** (Basal / Planting, Vegetative, Flowering, or Fruiting).
4. Tap **Calculate**:
   - The app specifies exact kilogram quantities of **Nitrogen (N)**, **Phosphorus (P)**, and **Potassium (K)**.
   - Recommends common bag formulas (e.g., NPK 15-15-15, Urea 46%, DAP).
   - Allows saving the calculated plan to your **Saved Fertilizer Plans**.

### 6.2 Pesticide Guide & Safety Manual
- Search a database of safe insecticides, fungicides, and herbicides.
- Learn proper dosage, dilution ratios per 16L knapsack sprayer, withholding periods (pre-harvest intervals), and protective gear requirements.

### 6.3 Pest & Disease Outbreak Alerts
- View regional warnings regarding locust swarms, armyworms, or blight outbreaks reported in nearby farming clusters.

---

## 7. Crop Library & Crop Calendar

### 7.1 Interactive Crop Library
Browse comprehensive agricultural guides for major crops:
- **Cereals & Grains:** Maize, Rice, Sorghum, Wheat.
- **Vegetables:** Tomato, Pepper, Cabbage, Onion.
- **Tubers & Roots:** Cassava, Yam, Potato, Sweet Potato.
- **Fruits & Legumes:** Banana, Beans, Groundnut, Soybean.

Each crop card covers:
- Optimal soil pH and temperature ranges.
- Water requirements and irrigation schedules.
- Spacing, seed rate, and sowing depths.
- Common pests and how to identify them early.

### 7.2 Crop Calendar
- Plan planting, weeding, fertilizer application, and harvesting dates based on your agro-ecological zone and wet/dry season cycles.

---

## 8. Weather & Agricultural Advisory

Tap the **Weather** tab on the bottom navigation bar:
- **Real-time Metrics:** Temperature, "Feels Like", Humidity %, Wind Speed (km/h), and Atmospheric Pressure.
- **Rainfall Probability:** Hourly forecast indicating chances of precipitation.
- **5-Day Extended Weather Forecast:** Plan your field operations for the coming week.
- **Smart Spraying & Field Advisory:**
  - 🟢 **Safe to Spray:** Low wind, no rain predicted for next 6 hours.
  - 🔴 **Do Not Spray:** High wind speeds (drift risk) or rain expected within 2 hours (wash-off risk).
  - 💧 **Irrigation Recommendation:** Calculates whether soil moisture is adequate based on recent precipitation.

---

## 9. AI Agronomist Chatbot

Tap the **Chat** icon on the Home screen to converse with your 24/7 personal agronomy specialist.

### What you can ask:
- *"What is the best fertilizer for flowering tomato plants?"*
- *"Why are my maize leaves turning purple at the edges?"*
- *"How do I prepare organic neem oil spray for aphid control?"*
- *"When should I harvest cassava after planting?"*

The chatbot combines agricultural knowledge with real-time agronomic models to provide clear, actionable advice.

---

## 10. Farmer Community Forum

Tap the **Community** tab on the bottom bar:

- **Browse Feed:** View questions, disease photos, harvest achievements, and discussions posted by other farmers.
- **Filter by Crop:** Tap crop chips (e.g., `#Maize`, `#Tomato`) to view discussions relevant to what you grow.
- **Create a Post:** Tap the floating `+` button:
  - Add a title and description of your field issue.
  - Attach photos from your camera or gallery.
  - Tag the relevant crop.
- **Help Others:** Comment on posts, share remedies that worked on your farm, and upvote helpful answers.

---

## 11. Agricultural News & Updates

Tap the **News** tab:
- Stay updated with the latest in agribusiness, government farming subsidies, commodity market price trends, and agricultural tech innovations.

---

## 12. User Profile, History & Settings

Tap the **Profile** tab:
- **My Diagnoses History:** View all past scans with photos, diagnoses, timestamps, and treatment outcomes.
- **Saved Fertilizer Plans:** Quick access to saved field fertilizer schedules.
- **Language Selection:** Switch between English and regional languages.
- **Theme Mode:** Toggle between Clean Light Mode and Battery-saving Dark Mode.
- **Help & Support:** FAQs, user guides, and contact support.
- **Account Management:** Edit personal details or sign out.

---

## 13. Offline Mode Capabilities

AgriDx is engineered to work reliably in remote farming regions where cellular data or internet coverage is weak or unavailable:

| Feature | When Online | When Offline |
| :--- | :--- | :--- |
| **Leaf Scanner (TFLite)** | ✅ Full AI Scan | ✅ Full On-Device AI Scan |
| **Disease Remedies** | ✅ Gemini AI + Offline Database | ✅ Comprehensive Offline Database |
| **History & Saved Plans** | ✅ Synced to Cloud | ✅ Stored locally in Hive DB |
| **Crop Library** | ✅ Full Access | ✅ Full Offline Access |
| **Fertilizer Calculator** | ✅ Full Access | ✅ Full Offline Access |
| **Weather Forecast** | ✅ Real-Time Live Data | ⚠️ Shows last cached weather |
| **Community & Chat** | ✅ Full Interaction | ⚠️ Requires internet connection |

---

## 14. Troubleshooting & Frequently Asked Questions

### Q1: The scanner says "Plant Healthy" or gave an unexpected diagnosis.
- **Solution:** Ensure the photo clearly shows the diseased section rather than healthy background foliage. Avoid blurry images and maintain good natural lighting. If the infection is unusual, consult the **AI Agronomist Chat** or post in the **Community Forum**.

### Q2: Android shows an "Unsafe App" or "Play Protect Warning" during APK install.
- **Solution:** Because you installed the APK directly rather than via Google Play Store, Google Play Protect may display a prompt. Tap **"More details"** -> **"Install anyway"**. The APK is safe and built directly from the verified AgriDx source code.

### Q3: Why is the weather not updating?
- **Solution:** Verify that your phone's GPS / Location service is turned ON and that you have granted AgriDx location permissions.

### Q4: How do I export or share diagnosis reports?
- **Solution:** Open the diagnosis result from **My Diagnoses** in your profile and tap the **Share** button to send a summary text and image via WhatsApp, Telegram, or Email.

---

*AgriDx — Healthy Crops, Abundant Harvests.*
