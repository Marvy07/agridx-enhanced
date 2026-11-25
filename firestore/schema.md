# AgriDX Enhanced — Firestore Schema

## Collections

### users/{uid}
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string|null",
  "farmType": "crop|livestock|mixed",
  "crops": ["string"],
  "animals": ["string"],
  "region": "string",
  "subscriptionTier": "free|premium|pro",
  "detectionsToday": 0,
  "detectionsResetAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### crops/{cropId}
```json
{
  "id": "string",
  "name": "string",
  "scientificName": "string",
  "description": "string",
  "imageUrl": "string",
  "thumbnailUrl": "string",
  "commonDiseases": ["diseaseId"],
  "growingRegions": ["string"],
  "plantingGuide": "string",
  "harvestGuide": "string",
  "growthDurationDays": 90,
  "category": "cereal|legume|vegetable|fruit|root|cash_crop",
  "updatedAt": "timestamp"
}
```

### animals/{animalId}
```json
{
  "id": "string",
  "name": "string",
  "species": "cattle|goat|poultry|pig|dog|cat",
  "description": "string",
  "imageUrl": "string",
  "commonDiseases": ["diseaseId"],
  "careGuide": "string",
  "breedInfo": "string",
  "vaccineSchedule": ["string"],
  "updatedAt": "timestamp"
}
```

### diseases/{diseaseId}
```json
{
  "id": "string",
  "name": "string",
  "type": "plant|animal",
  "affectedSpecies": ["string"],
  "symptoms": ["string"],
  "description": "string",
  "treatment": "string",
  "severity": "low|medium|high|critical",
  "imageUrls": ["string"],
  "modelClass": "string",
  "preventionTips": ["string"],
  "isNotifiable": false,
  "updatedAt": "timestamp"
}
```

### detections/{detectionId}
```json
{
  "id": "string",
  "userId": "string",
  "type": "plant|animal",
  "subjectName": "string",
  "diseaseName": "string",
  "confidence": 0.95,
  "severity": "low|medium|high",
  "imageUrl": "string",
  "modelVersion": "string",
  "treatments": ["string"],
  "location": {"region": "string", "lat": null, "lng": null},
  "createdAt": "timestamp"
}
```

### subscriptions/{userId}
```json
{
  "userId": "string",
  "tier": "free|premium|pro",
  "validUntil": "timestamp|null",
  "paystackCustomerId": "string|null",
  "paystackSubscriptionCode": "string|null",
  "stripeCustomerId": "string|null",
  "stripeSubscriptionId": "string|null",
  "revenuecatUserId": "string|null",
  "platform": "android|ios|web",
  "updatedAt": "timestamp"
}
```

### alerts/{alertId}
```json
{
  "id": "string",
  "userId": "string",
  "type": "disease_outbreak|weather_risk|seasonal_advisory",
  "cropOrAnimal": "string",
  "region": "string",
  "diseaseId": "string|null",
  "title": "string",
  "body": "string",
  "severity": "low|medium|high",
  "sentAt": "timestamp",
  "readAt": "timestamp|null",
  "channel": "fcm|email"
}
```

### alert_subscriptions/{userId}/subscribed/{itemId}
```json
{
  "itemId": "string",
  "type": "crop|animal",
  "region": "string",
  "createdAt": "timestamp"
}
```

## Security Rules (Firestore)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Detections: users own their own
    match /detections/{detectionId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }

    // Crops and animals: public read, admin write only
    match /crops/{cropId} {
      allow read: if true;
      allow write: if false; // backend only via Admin SDK
    }
    match /animals/{animalId} {
      allow read: if true;
      allow write: if false;
    }
    match /diseases/{diseaseId} {
      allow read: if true;
      allow write: if false;
    }

    // Subscriptions: user read own, backend writes
    match /subscriptions/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // backend only
    }

    // Alerts: user reads own
    match /alerts/{alertId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if false;
    }

    // Alert subscriptions: user manages own
    match /alert_subscriptions/{userId}/subscribed/{itemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Community: authenticated read/write
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && resource.data.authorId == request.auth.uid;
    }
  }
}
```
