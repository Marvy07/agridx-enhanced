import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        }
      }
    } catch (e) {
      print('Error fetching user model: $e');
    }
    return null;
  }

  Stream<UserModel?> getCurrentUserModelStream() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return _db.collection('users').doc(user.uid).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        }
        return null;
      });
    }
    return Stream.value(null);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _updateUserData(userCredential.user!);
      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password, String name, {String location = '', String farmerType = 'Smallholder'}) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        location: location,
        farmerType: farmerType,
        joinDate: DateTime.now(),
      );

      var userMap = newUser.toMap();
      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        userMap['fcmToken'] = fcmToken;
      }

      await _db.collection('users').doc(newUser.uid).set(userMap);
      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  Future<void> signInAsGuest() async {
    final box = await Hive.openBox('user_preferences');
    await box.put('isGuestMode', true);
  }

  Future<void> signOut() async {
    final box = await Hive.openBox('user_preferences');
    await box.put('isGuestMode', false);
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Exception _handleFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      return e;
    }
    
    final errorStr = e.toString();
    
    // Explicitly handle the 'type FirebaseException is not a subtype of JavaScriptObject' error
    if (errorStr.contains('FirebaseException') && errorStr.contains('JavaScriptObject')) {
      print('Detected Firebase Web Interop mismatch. Likely missing Web configuration.');
      return Exception('Firebase not configured for Web. Please run "flutterfire configure" to add Web support to your project.');
    }

    // On Web, exceptions from Firebase JS SDK sometimes come as generic objects
    // that don't cast well to FirebaseException in Dart.
    if (errorStr.contains('firebase_auth/') || errorStr.contains('FirebaseError')) {
      print('Caught Firebase JS Error on Web: $errorStr');
      return Exception(errorStr.split(']').last.trim());
    }
    
    print('Unknown auth error: $e');
    return Exception(e.toString());
  }

  Future<void> _updateUserData(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();
    
    final fcmToken = await NotificationService.getToken();

    if (!doc.exists) {
      final UserModel newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'New Farmer',
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        joinDate: DateTime.now(),
      );
      
      var userMap = newUser.toMap();
      if (fcmToken != null) userMap['fcmToken'] = fcmToken;
      
      await docRef.set(userMap);
    } else {
      if (fcmToken != null) {
        await docRef.update({'fcmToken': fcmToken});
      }
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    await _db.collection('users').doc(updatedUser.uid).update(updatedUser.toMap());
  }

  Future<String?> uploadProfileImage({
    required String userId, 
    Uint8List? bytes,
    String? filePath,
  }) async {
    try {
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance.ref().child('users').child(userId).child('profile_pictures').child(fileName);
      
      final SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      
      UploadTask uploadTask;
      if (!kIsWeb && filePath != null) {
        uploadTask = ref.putFile(File(filePath), metadata);
      } else if (bytes != null) {
        uploadTask = ref.putData(bytes, metadata);
      } else {
        throw Exception('No image data provided');
      }
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Upload failed: $e');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userModelProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(authServiceProvider).getCurrentUserModelStream();
});
