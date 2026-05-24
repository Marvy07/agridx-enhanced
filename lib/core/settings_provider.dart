import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class SettingsState {
  final bool receiveCropsNotif;
  final bool receivePopularPostsNotif;
  final bool receiveAnswerNotif;
  final bool receiveUpvoteNotif;
  final bool receiveFollowerNotif;
  final bool receiveFollowingPostNotif;
  final bool receiveCommentNotif;
  final bool googleAnalytics;
  final bool crashReporting;

  SettingsState({
    this.receiveCropsNotif = true,
    this.receivePopularPostsNotif = true,
    this.receiveAnswerNotif = true,
    this.receiveUpvoteNotif = true,
    this.receiveFollowerNotif = true,
    this.receiveFollowingPostNotif = true,
    this.receiveCommentNotif = false,
    this.googleAnalytics = false,
    this.crashReporting = false,
  });

  SettingsState copyWith({
    bool? receiveCropsNotif,
    bool? receivePopularPostsNotif,
    bool? receiveAnswerNotif,
    bool? receiveUpvoteNotif,
    bool? receiveFollowerNotif,
    bool? receiveFollowingPostNotif,
    bool? receiveCommentNotif,
    bool? googleAnalytics,
    bool? crashReporting,
  }) {
    return SettingsState(
      receiveCropsNotif: receiveCropsNotif ?? this.receiveCropsNotif,
      receivePopularPostsNotif: receivePopularPostsNotif ?? this.receivePopularPostsNotif,
      receiveAnswerNotif: receiveAnswerNotif ?? this.receiveAnswerNotif,
      receiveUpvoteNotif: receiveUpvoteNotif ?? this.receiveUpvoteNotif,
      receiveFollowerNotif: receiveFollowerNotif ?? this.receiveFollowerNotif,
      receiveFollowingPostNotif: receiveFollowingPostNotif ?? this.receiveFollowingPostNotif,
      receiveCommentNotif: receiveCommentNotif ?? this.receiveCommentNotif,
      googleAnalytics: googleAnalytics ?? this.googleAnalytics,
      crashReporting: crashReporting ?? this.crashReporting,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;

  SettingsNotifier(this.prefs) : super(SettingsState(
    receiveCropsNotif: prefs.getBool('receiveCropsNotif') ?? true,
    receivePopularPostsNotif: prefs.getBool('receivePopularPostsNotif') ?? true,
    receiveAnswerNotif: prefs.getBool('receiveAnswerNotif') ?? true,
    receiveUpvoteNotif: prefs.getBool('receiveUpvoteNotif') ?? true,
    receiveFollowerNotif: prefs.getBool('receiveFollowerNotif') ?? true,
    receiveFollowingPostNotif: prefs.getBool('receiveFollowingPostNotif') ?? true,
    receiveCommentNotif: prefs.getBool('receiveCommentNotif') ?? false,
    googleAnalytics: prefs.getBool('googleAnalytics') ?? false,
    crashReporting: prefs.getBool('crashReporting') ?? false,
  ));

  void toggleReceiveCropsNotif(bool value) {
    prefs.setBool('receiveCropsNotif', value);
    state = state.copyWith(receiveCropsNotif: value);
  }

  void toggleReceivePopularPostsNotif(bool value) {
    prefs.setBool('receivePopularPostsNotif', value);
    state = state.copyWith(receivePopularPostsNotif: value);
  }

  void toggleReceiveAnswerNotif(bool value) async {
    prefs.setBool('receiveAnswerNotif', value);
    state = state.copyWith(receiveAnswerNotif: value);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'receiveAnswerNotif': value});
      }
    } catch (_) {}
  }

  void toggleReceiveUpvoteNotif(bool value) {
    prefs.setBool('receiveUpvoteNotif', value);
    state = state.copyWith(receiveUpvoteNotif: value);
  }

  void toggleReceiveFollowerNotif(bool value) {
    prefs.setBool('receiveFollowerNotif', value);
    state = state.copyWith(receiveFollowerNotif: value);
  }

  void toggleReceiveFollowingPostNotif(bool value) {
    prefs.setBool('receiveFollowingPostNotif', value);
    state = state.copyWith(receiveFollowingPostNotif: value);
  }

  void toggleReceiveCommentNotif(bool value) {
    prefs.setBool('receiveCommentNotif', value);
    state = state.copyWith(receiveCommentNotif: value);
  }

  void toggleGoogleAnalytics(bool value) {
    prefs.setBool('googleAnalytics', value);
    state = state.copyWith(googleAnalytics: value);
  }

  void toggleCrashReporting(bool value) {
    prefs.setBool('crashReporting', value);
    state = state.copyWith(crashReporting: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
