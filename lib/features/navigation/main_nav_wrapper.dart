import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme_provider.dart';
import '../../core/localization_provider.dart';

class MainNavigationWrapper extends ConsumerWidget {
  final Widget child;

  const MainNavigationWrapper({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/detect') ||
        location.startsWith('/scan') ||
        location.startsWith('/symptom-check')) return 1;
    if (location.startsWith('/library')) return 2;
    if (location.startsWith('/animals')) return 3;
    if (location.startsWith('/community')) return 4;
    if (location.startsWith('/weather')) return 5;
    if (location.startsWith('/news')) return 6;
    if (location.startsWith('/profile')) return 7;
    return 0;
  }

  String _indexToRoute(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/detect';
      case 2:
        return '/library';
      case 3:
        return '/animals';
      case 4:
        return '/community';
      case 5:
        return '/weather';
      case 6:
        return '/news';
      case 7:
        return '/profile';
      default:
        return '/home';
    }
  }

  void _showGuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Up Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Join the AgriDx community to connect with other farmers, share tips, and set up your personal profile!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Hive.box('user_preferences').put('isGuestMode', false);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    final themeColor = ref.watch(themeColorProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: themeColor.withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B263B),
                  letterSpacing: 0.2,
                );
              }
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF1B263B), size: 28);
              }
              return const IconThemeData(color: Colors.black45, size: 24);
            }),
          ),
          child: NavigationBar(
            height: 75,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              // Community (4) and Profile (7) require auth
              if (index == 4 || index == 7) {
                final isGuestMode = Hive.box('user_preferences')
                    .get('isGuestMode', defaultValue: false);
                if (isGuestMode) {
                  _showGuestDialog(context);
                  return;
                }
              }
              context.go(_indexToRoute(index));
            },
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.eco_outlined),
                selectedIcon: const Icon(Icons.eco),
                label: strings['nav_crops'] ?? 'Crops',
              ),
              const NavigationDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: 'Detect',
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: strings['nav_library'] ?? 'Library',
              ),
              const NavigationDestination(
                icon: Icon(Icons.pets_outlined),
                selectedIcon: Icon(Icons.pets),
                label: 'Animals',
              ),
              NavigationDestination(
                icon: const Icon(Icons.forum_outlined),
                selectedIcon: const Icon(Icons.forum),
                label: strings['nav_community'] ?? 'Community',
              ),
              NavigationDestination(
                icon: const Icon(Icons.cloud_outlined),
                selectedIcon: const Icon(Icons.cloud),
                label: strings['nav_weather'] ?? 'Weather',
              ),
              NavigationDestination(
                icon: const Icon(Icons.newspaper_outlined),
                selectedIcon: const Icon(Icons.newspaper),
                label: strings['nav_news'] ?? 'News',
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: strings['nav_profile'] ?? 'You',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
