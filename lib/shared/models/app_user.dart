import '../../features/subscription/models/subscription_tier.dart';

enum FarmType {
  crop,
  livestock,
  mixed,
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final FarmType farmType;
  final List<String> crops;
  final List<String> animals;
  final String region;
  final SubscriptionTier subscriptionTier;
  final int detectionsToday;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.farmType,
    required this.crops,
    required this.animals,
    required this.region,
    required this.subscriptionTier,
    required this.detectionsToday,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      farmType: FarmType.values.firstWhere(
        (f) => f.name == json['farm_type'],
        orElse: () => FarmType.mixed,
      ),
      crops: List<String>.from(json['crops'] as List),
      animals: List<String>.from(json['animals'] as List),
      region: json['region'] as String,
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['subscription_tier'],
        orElse: () => SubscriptionTier.free,
      ),
      detectionsToday: json['detections_today'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'farm_type': farmType.name,
        'crops': crops,
        'animals': animals,
        'region': region,
        'subscription_tier': subscriptionTier.name,
        'detections_today': detectionsToday,
        'created_at': createdAt.toIso8601String(),
      };
}
