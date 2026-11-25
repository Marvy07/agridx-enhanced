import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/scan/crop_scan_screen.dart';
import '../features/library/library_screen.dart';

import '../features/community/community_screen.dart';
import '../features/community/post_detail_screen.dart';
import '../features/community/services/community_service.dart';
import '../features/chat/chat_screen.dart';
import '../features/weather/weather_screen.dart';
import '../features/news/news_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/navigation/main_nav_wrapper.dart';
import '../features/detection/detection_screen.dart';
import '../features/detection/animal_detection_screen.dart';
import '../features/detection/symptom_check_screen.dart';
import '../features/animals/animal_list_screen.dart';
import '../features/animals/animal_detail_screen.dart';
import '../features/subscription/subscription_screen.dart';

final authStateProvider = Provider<String?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationWrapper(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/scan/plant',
            builder: (context, state) => const CropScanScreen(),
          ),
          GoRoute(
            path: '/scan/animal',
            builder: (context, state) => const AnimalDetectionScreen(),
          ),
          GoRoute(
            path: '/symptom-check',
            builder: (context, state) => const SymptomCheckScreen(),
          ),
          GoRoute(
            path: '/detect',
            builder: (context, state) => const DetectionScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
            routes: [
              GoRoute(
                path: ':cropId',
                builder: (context, state) {
                  final cropId = state.pathParameters['cropId']!;
                  return _PlaceholderScreen(title: 'Crop $cropId');
                },
              ),
            ],
          ),
          GoRoute(
            path: '/animals',
            builder: (context, state) => const AnimalListScreen(),
            routes: [
              GoRoute(
                path: ':animalId',
                builder: (context, state) {
                  final animalId = state.pathParameters['animalId']!;
                  return AnimalDetailScreen(animalId: animalId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
            routes: [
              GoRoute(
                path: ':postId',
                builder: (context, state) {
                  final postId = state.pathParameters['postId']!;
                  return _PostDetailWrapper(postId: postId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/weather',
            builder: (context, state) => const WeatherScreen(),
          ),
          GoRoute(
            path: '/news',
            builder: (context, state) => const NewsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
              ),
              GoRoute(
                path: 'diagnoses',
                builder: (context, state) => const _PlaceholderScreen(title: 'My Diagnoses'),
              ),
            ],
          ),
          GoRoute(
            path: '/subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
        ],
      ),
    ],
  );
});

class _PostDetailWrapper extends ConsumerWidget {
  final String postId;
  const _PostDetailWrapper({required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(communityServiceProvider).getPost(postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Post not found')),
          );
        }
        return PostDetailScreen(post: snapshot.data!);
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title coming soon')),
    );
  }
}
