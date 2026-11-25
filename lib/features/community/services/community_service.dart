import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/community_models.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/auth_service.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<CommunityPost>> getPostsStream({String cropType = 'All', String searchQuery = '', int limit = 10}) {
    // To bypass the need for a Firestore Composite Index in this phase,
    // we fetch the latest posts and filter them client-side.
    int fetchLimit = cropType == 'All' ? limit : limit * 5; 
    
    Query query = _db.collection('posts').orderBy('timestamp', descending: true);

    return query.limit(fetchLimit).snapshots().map((snapshot) {
      var posts = snapshot.docs.map((doc) => CommunityPost.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      
      // Filter out dummy system posts locally since we don't have permission to delete them
      posts = posts.where((post) => post.userId != 'system').toList();
      
      if (cropType != 'All') {
        posts = posts.where((post) => post.cropType == cropType).toList();
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        posts = posts.where((post) => 
          post.title.toLowerCase().contains(query) ||
          post.body.toLowerCase().contains(query) ||
          post.userName.toLowerCase().contains(query) ||
          post.cropType.toLowerCase().contains(query)
        ).toList();
      }
      
      // Ensure we only return up to the requested limit
      return posts.take(limit).toList();
    });
  }

  Future<void> addPost(CommunityPost post) async {
    final batch = _db.batch();
    batch.set(_db.collection('posts').doc(post.postId), post.toMap());
    
    if (post.userId.isNotEmpty && post.userId != 'system') {
      batch.update(_db.collection('users').doc(post.userId), {
        'communityPoints': FieldValue.increment(5), // +5 pts for post
      });
    }
    
    await batch.commit();
  }

  Future<void> updatePost(CommunityPost post) async {
    await _db.collection('posts').doc(post.postId).update(post.toMap());
  }

  Future<CommunityPost?> getPost(String postId) async {
    final doc = await _db.collection('posts').doc(postId).get();
    if (!doc.exists || doc.data() == null) return null;
    return CommunityPost.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }

  Future<void> updateUserAvatar(String userId, String newAvatarUrl) async {
    final batch = _db.batch();

    try {
      // Update all posts made by this user
      final posts = await _db.collection('posts').where('userId', isEqualTo: userId).get();
      for (final post in posts.docs) {
        batch.update(post.reference, {'userAvatar': newAvatarUrl});
      }
    } catch (e) {
      print('Failed to sync avatar to posts: $e');
    }

    try {
      // Update all answers made by this user using a collectionGroup query
      final answers = await _db.collectionGroup('answers').where('userId', isEqualTo: userId).get();
      for (final answer in answers.docs) {
        batch.update(answer.reference, {'userAvatar': newAvatarUrl});
      }
    } catch (e) {
      print('Failed to sync avatar to answers (Index required): $e');
    }

    try {
      await batch.commit();
    } catch (e) {
      print('Failed to commit avatar sync: $e');
    }
  }

  Future<String?> uploadPostImage({
    required String userId, 
    Uint8List? bytes,
    String? filePath,
    required Function(double) onProgress
  }) async {
    try {
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('community').child('posts').child(fileName);
      
      final SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      
      UploadTask uploadTask;
      if (!kIsWeb && filePath != null) {
        uploadTask = ref.putFile(File(filePath), metadata);
      } else if (bytes != null) {
        uploadTask = ref.putData(bytes, metadata);
      } else {
        throw Exception('No image data provided');
      }
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });
      
      // Increased timeout to 90 seconds to accommodate slower mobile networks
      final TaskSnapshot snapshot = await uploadTask.timeout(const Duration(seconds: 90));
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      throw e; // Rethrow so the UI can show the exact error
    }
  }

  Future<void> addAnswer(String postId, CommunityAnswer answer) async {
    final batch = _db.batch();
    
    final answerRef = _db.collection('posts').doc(postId).collection('answers').doc(answer.answerId);
    batch.set(answerRef, answer.toMap());
    
    final postRef = _db.collection('posts').doc(postId);
    batch.update(postRef, {'answersCount': FieldValue.increment(1)});
    
    if (answer.userId.isNotEmpty && answer.userId != 'system') {
      batch.update(_db.collection('users').doc(answer.userId), {
        'communityPoints': FieldValue.increment(10), // +10 pts for answering
      });
    }
    
    await batch.commit();
  }

  Future<void> deleteAnswer(String postId, String answerId) async {
    final answerRef = _db.collection('posts').doc(postId).collection('answers').doc(answerId);
    
    // Perform operations sequentially instead of a batch, so if one fails due to rules, the others might succeed.
    await answerRef.delete();
    
    try {
      final postRef = _db.collection('posts').doc(postId);
      await postRef.update({'answersCount': FieldValue.increment(-1)});
    } catch (e) {
      print('Could not decrement answersCount: $e');
    }
  }

  Stream<List<CommunityAnswer>> getAnswersStream(String postId) {
    return _db.collection('posts').doc(postId).collection('answers')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CommunityAnswer.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> toggleLikePost(String postId, String userId, bool isLike) async {
    final userRef = _db.collection('users').doc(userId);
    final postRef = _db.collection('posts').doc(postId);
    
    await _db.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;
      
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      final userData = userDoc.data()!;
      final postData = postDoc.data()!;

      final likedPosts = List<String>.from(userData['likedPosts'] ?? []);
      final dislikedPosts = List<String>.from(userData['dislikedPosts'] ?? []);
      
      int currentLikes = postData['likes'] as int? ?? 0;
      int currentDislikes = postData['dislikes'] as int? ?? 0;

      // Ensure we don't start negative due to past bugs
      if (currentLikes < 0) currentLikes = 0;
      if (currentDislikes < 0) currentDislikes = 0;

      int likerPointsDelta = 0;
      int authorPointsDelta = 0;

      if (isLike) {
        if (likedPosts.contains(postId)) {
          // Unlike
          likedPosts.remove(postId);
          currentLikes = (currentLikes > 0) ? currentLikes - 1 : 0;
          likerPointsDelta = -1;
          authorPointsDelta = -2;
        } else {
          // Like
          likedPosts.add(postId);
          currentLikes += 1;
          likerPointsDelta = 1;
          authorPointsDelta = 2;
          // Remove from dislikes if it was there
          if (dislikedPosts.contains(postId)) {
            dislikedPosts.remove(postId);
            currentDislikes = (currentDislikes > 0) ? currentDislikes - 1 : 0;
          }
        }
      } else {
        if (dislikedPosts.contains(postId)) {
          // Undislike
          dislikedPosts.remove(postId);
          currentDislikes = (currentDislikes > 0) ? currentDislikes - 1 : 0;
        } else {
          // Dislike
          dislikedPosts.add(postId);
          currentDislikes += 1;
          // Remove from likes if it was there
          if (likedPosts.contains(postId)) {
            likedPosts.remove(postId);
            currentLikes = (currentLikes > 0) ? currentLikes - 1 : 0;
            likerPointsDelta = -1;
            authorPointsDelta = -2;
          }
        }
      }

      final Map<String, dynamic> userUpdates = {
        'likedPosts': likedPosts,
        'dislikedPosts': dislikedPosts,
      };
      if (likerPointsDelta != 0) {
        userUpdates['communityPoints'] = FieldValue.increment(likerPointsDelta);
      }
      transaction.update(userRef, userUpdates);
      transaction.update(postRef, {
        'likes': currentLikes,
        'dislikes': currentDislikes,
      });

      // Update author's points if the author is not the liker
      final authorId = postData['userId'] as String?;
      if (authorId != null && authorId != userId && authorPointsDelta != 0) {
        final authorRef = _db.collection('users').doc(authorId);
        transaction.update(authorRef, {
          'communityPoints': FieldValue.increment(authorPointsDelta)
        });
      }

      // Note: We cannot update another user's document directly from the client
      // due to standard Firestore security rules (Permission Denied). 
      // If we need to award points to authors for likes, it should be done 
      // via a Firebase Cloud Function.
    });
  }

  Future<void> toggleLikeAnswer(String postId, String answerId, String userId, bool isLike) async {
    final answerRef = _db.collection('posts').doc(postId).collection('answers').doc(answerId);
    
    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(answerRef);
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final dislikedBy = List<String>.from(data['dislikedBy'] ?? []);
      int currentLikes = data['likes'] as int? ?? 0;
      int currentDislikes = data['dislikes'] as int? ?? 0;

      if (currentLikes < 0) currentLikes = 0;
      if (currentDislikes < 0) currentDislikes = 0;

      if (isLike) {
        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          currentLikes = (currentLikes > 0) ? currentLikes - 1 : 0;
        } else {
          // Like
          likedBy.add(userId);
          currentLikes += 1;
          if (dislikedBy.contains(userId)) {
            dislikedBy.remove(userId);
            currentDislikes = (currentDislikes > 0) ? currentDislikes - 1 : 0;
          }
        }
      } else {
        if (dislikedBy.contains(userId)) {
          // Undislike
          dislikedBy.remove(userId);
          currentDislikes = (currentDislikes > 0) ? currentDislikes - 1 : 0;
        } else {
          // Dislike
          dislikedBy.add(userId);
          currentDislikes += 1;
          if (likedBy.contains(userId)) {
            likedBy.remove(userId);
            currentLikes = (currentLikes > 0) ? currentLikes - 1 : 0;
          }
        }
      }

      transaction.update(answerRef, {
        'likedBy': likedBy,
        'dislikedBy': dislikedBy,
        'likes': currentLikes,
        'dislikes': currentDislikes,
      });
      // Earns no points
    });
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    final userRef = _db.collection('users').doc(currentUserId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) return;
    
    final following = List<String>.from(userDoc.data()?['following'] ?? []);
    if (following.contains(targetUserId)) {
      following.remove(targetUserId);
    } else {
      following.add(targetUserId);
    }
    await userRef.update({'following': following});
  }

  Future<void> toggleBlock(String currentUserId, String targetUserId) async {
    final userRef = _db.collection('users').doc(currentUserId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) return;
    
    final blockedUsers = List<String>.from(userDoc.data()?['blockedUsers'] ?? []);
    if (blockedUsers.contains(targetUserId)) {
      blockedUsers.remove(targetUserId);
    } else {
      blockedUsers.add(targetUserId);
    }
    await userRef.update({'blockedUsers': blockedUsers});
  }

  Future<void> reportUser(String currentUserId, String reportedUserId, String reason) async {
    await _db.collection('reports').add({
      'reporterId': currentUserId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> clearDummyData() async {
    final batch = _db.batch();
    for (int i = 1; i <= 5; i++) {
      batch.delete(_db.collection('posts').doc('seed-$i'));
      try {
        final answers = await _db.collection('posts').doc('seed-$i').collection('answers').get();
        for (var a in answers.docs) {
          batch.delete(a.reference);
        }
      } catch (e) {
        // ignore if doesn't exist
      }
    }
    await batch.commit();
  }
  Stream<List<CommunityPost>> getMyPostsStream(String userId, {int limit = 100}) {
    // Client-side filtering to avoid requiring a composite index
    Query query = _db.collection('posts').orderBy('timestamp', descending: true);
    return query.limit(limit).snapshots().map((snapshot) {
      var posts = snapshot.docs.map((doc) => CommunityPost.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      return posts.where((post) => post.userId == userId).toList();
    });
  }
}

final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService();
});

final communityPostsProvider = StreamProvider.family<List<CommunityPost>, ({String cropType, String searchQuery, int limit})>((ref, params) {
  return ref.watch(communityServiceProvider).getPostsStream(
    cropType: params.cropType,
    searchQuery: params.searchQuery,
    limit: params.limit,
  );
});

final myPostsProvider = StreamProvider.family<List<CommunityPost>, String>((ref, userId) {
  return ref.watch(communityServiceProvider).getMyPostsStream(userId);
});
