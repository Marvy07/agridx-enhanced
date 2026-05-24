import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String postId;
  final String userId;
  final String userName;
  final String userLocation;
  final String userAvatar;
  final String cropType;
  final String cropEmoji;
  final String title;
  final String body;
  final List<String> hashtags;
  final String imageUrl;
  final int likes;
  final int dislikes;
  final int answersCount;
  final DateTime timestamp;
  final bool isTranslated;

  CommunityPost({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userLocation,
    required this.userAvatar,
    required this.cropType,
    required this.cropEmoji,
    required this.title,
    required this.body,
    required this.hashtags,
    this.imageUrl = '',
    this.likes = 0,
    this.dislikes = 0,
    this.answersCount = 0,
    required this.timestamp,
    this.isTranslated = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userLocation': userLocation,
      'userAvatar': userAvatar,
      'cropType': cropType,
      'cropEmoji': cropEmoji,
      'title': title,
      'body': body,
      'hashtags': hashtags,
      'imageUrl': imageUrl,
      'likes': likes,
      'dislikes': dislikes,
      'answersCount': answersCount,
      'timestamp': Timestamp.fromDate(timestamp),
      'isTranslated': isTranslated,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPost(
      postId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userLocation: map['userLocation'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      cropType: map['cropType'] ?? 'All',
      cropEmoji: map['cropEmoji'] ?? '🌍',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      answersCount: map['answersCount'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTranslated: map['isTranslated'] ?? false,
    );
  }
}

class CommunityAnswer {
  final String answerId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String body;
  final int likes;
  final int dislikes;
  final List<String> likedBy;
  final List<String> dislikedBy;
  final DateTime timestamp;

  CommunityAnswer({
    required this.answerId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.body,
    this.likes = 0,
    this.dislikes = 0,
    this.likedBy = const [],
    this.dislikedBy = const [],
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'answerId': answerId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'body': body,
      'likes': likes,
      'dislikes': dislikes,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory CommunityAnswer.fromMap(Map<String, dynamic> map, String id) {
    return CommunityAnswer(
      answerId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      body: map['body'] ?? '',
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      dislikedBy: List<String>.from(map['dislikedBy'] ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
