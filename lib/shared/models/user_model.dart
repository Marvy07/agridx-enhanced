import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoURL;
  final String location;
  final String farmerType;
  final DateTime joinDate;
  final int totalScans;
  final int totalDiagnoses;
  final List<String> savedDiagnoses;
  final List<String> likedPosts;
  final List<String> dislikedPosts;
  final int communityPoints;
  final String language;
  final List<String> following;
  final List<String> blockedUsers;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL = '',
    this.location = '',
    this.farmerType = 'Smallholder',
    required this.joinDate,
    this.totalScans = 0,
    this.totalDiagnoses = 0,
    this.savedDiagnoses = const [],
    this.likedPosts = const [],
    this.dislikedPosts = const [],
    this.communityPoints = 0,
    this.language = 'English',
    this.following = const [],
    this.blockedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'location': location,
      'farmerType': farmerType,
      'joinDate': Timestamp.fromDate(joinDate),
      'totalScans': totalScans,
      'totalDiagnoses': totalDiagnoses,
      'savedDiagnoses': savedDiagnoses,
      'likedPosts': likedPosts,
      'dislikedPosts': dislikedPosts,
      'communityPoints': communityPoints,
      'language': language,
      'following': following,
      'blockedUsers': blockedUsers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'] ?? '',
      location: map['location'] ?? '',
      farmerType: map['farmerType'] ?? 'Smallholder',
      joinDate: (map['joinDate'] as Timestamp).toDate(),
      totalScans: map['totalScans'] ?? 0,
      totalDiagnoses: map['totalDiagnoses'] ?? 0,
      savedDiagnoses: List<String>.from(map['savedDiagnoses'] ?? []),
      likedPosts: List<String>.from(map['likedPosts'] ?? []),
      dislikedPosts: List<String>.from(map['dislikedPosts'] ?? []),
      communityPoints: map['communityPoints'] ?? 0,
      language: map['language'] ?? 'English',
      following: List<String>.from(map['following'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    String? location,
    String? farmerType,
    DateTime? joinDate,
    int? totalScans,
    int? totalDiagnoses,
    List<String>? savedDiagnoses,
    List<String>? likedPosts,
    List<String>? dislikedPosts,
    int? communityPoints,
    String? language,
    List<String>? following,
    List<String>? blockedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      location: location ?? this.location,
      farmerType: farmerType ?? this.farmerType,
      joinDate: joinDate ?? this.joinDate,
      totalScans: totalScans ?? this.totalScans,
      totalDiagnoses: totalDiagnoses ?? this.totalDiagnoses,
      savedDiagnoses: savedDiagnoses ?? this.savedDiagnoses,
      likedPosts: likedPosts ?? this.likedPosts,
      dislikedPosts: dislikedPosts ?? this.dislikedPosts,
      communityPoints: communityPoints ?? this.communityPoints,
      language: language ?? this.language,
      following: following ?? this.following,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }
}

extension CommunityRank on UserModel {
  String get rankName {
    if (communityPoints < 50) return 'Beginner';
    if (communityPoints < 200) return 'Intermediate';
    if (communityPoints < 500) return 'Expert';
    return 'Master';
  }

  String get rankIcon {
    if (communityPoints < 50) return '🌱'; // Seed
    if (communityPoints < 200) return '🌿'; // Plant
    if (communityPoints < 500) return '🚀'; // Rocket
    return '👑'; // Crown
  }
}
