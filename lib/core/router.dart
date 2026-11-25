import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/community/community_screen.dart';
import '../features/community/post_detail_screen.dart';
import '../features/detection/detection_screen.dart';
import '../features/detection/animal_detection_screen.dart';
import '../features/detection/symptom_check_screen.dart';
import '../features/detection/detection_result_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/animals/animal_list_screen.dart';
import '../features/animals/animal_detail_screen.dart';
import '../features/news/news_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/profile/my_diagnoses_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/subscription/subscription_screen.dart';
import '../features/weather/weather_screen.dart';
import '../shared/services/auth_service.dart';
import '../shared/widgets/app_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ValueNotifier<bool>(false);
  ref.listen(authStateProvider, (_, next) {
    final prefs = Hive.box('user_preferences');
    final isGuest = prefs.get('isGuestMode', defaultValue: false) as bool;
    authNotifier.value = next.value != null || isGuest;
  });

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final prefs = Hive.box('user_preferences');
      final isGuest = prefs.get('isGuestMode', defaultValue: false) as bool;
      final hasSeenOnboarding = prefs.get('hasSeenOnboarding', defaultValue: false) as bool;

      final loggedIn = authNotifier.value;
      final onAuthPath = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/splash';

      if (state.matchedLocation == '/splash') return null;
      if (!loggedIn && !isGuest) {
        if (!hasSeenOnboarding) return '/onboarding';
        return onAuthPath ? null : '/login';
      }
      if (loggedIn && onAuthPath) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Shell with bottom nav
      ShellRoute(
        builder: (context, state, child) {
          final index = _navIndexFor(state.matchedLocation);
          return AppBottomNav(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => _fadePage(const HomeScreen()),
          ),
          GoRoute(
            path: '/scan/plant',
            pageBuilder: (_, __) => _fadePage(const DetectionScreen()),
            routes: [
              GoRoute(path: 'animal', builder: (_, __) => const AnimalDetectionScreen()),
              GoRoute(path: 'symptom', builder: (_, __) => const SymptomCheckScreen()),
              GoRoute(
                path: 'result',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return DetectionResultScreen(result: extra);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (_, __) => _fadePage(const LibraryScreen()),
            routes: [
              GoRoute(
                path: ':cropId',
                builder: (context, state) =>
                    _CropDetailWrapper(cropId: state.pathParameters['cropId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/animals',
            pageBuilder: (_, __) => _fadePage(const AnimalListScreen()),
            routes: [
              GoRoute(
                path: ':animalId',
                builder: (context, state) =>
                    AnimalDetailScreen(animalId: state.pathParameters['animalId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (_, __) => _fadePage(const CommunityScreen()),
            routes: [
              GoRoute(
                path: ':postId',
                builder: (context, state) =>
                    PostDetailScreen(post: state.extra as dynamic),
              ),
            ],
          ),
          GoRoute(path: '/weather', pageBuilder: (_, __) => _fadePage(const WeatherScreen())),
          GoRoute(path: '/news', pageBuilder: (_, __) => _fadePage(const NewsScreen())),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
            routes: [
              GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
              GoRoute(path: 'diagnoses', builder: (_, __) => const MyDiagnosesScreen()),
              GoRoute(path: 'notifications', builder: (_, __) => const NotificationScreen()),
              GoRoute(path: 'subscription', builder: (_, __) => const SubscriptionScreen()),
              GoRoute(path: 'chat', builder: (_, __) => const ChatScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

int _navIndexFor(String location) {
  if (location.startsWith('/scan')) return 1;
  if (location.startsWith('/library')) return 2;
  if (location.startsWith('/animals')) return 3;
  if (location.startsWith('/community')) return 4;
  if (location.startsWith('/weather')) return 5;
  if (location.startsWith('/news')) return 6;
  if (location.startsWith('/profile')) return 7;
  return 0;
}

// Temporary wrapper until CropDetailScreen API is updated to accept cropId
class _CropDetailWrapper extends StatelessWidget {
  const _CropDetailWrapper({required this.cropId});
  final String cropId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cropId)),
      body: Center(child: Text('Crop detail for: \$cropId')),
    );
  }
}
