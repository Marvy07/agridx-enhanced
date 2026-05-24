import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/navigation_provider.dart';
import '../home/home_screen.dart';
import '../community/community_screen.dart';
import '../weather/weather_screen.dart';
import '../profile/profile_screen.dart';
import '../news/news_screen.dart';
import '../../core/theme_provider.dart';
import '../../core/localization_provider.dart';

class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({super.key});

  void _showGuestDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Up Required', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Join the AgriDx community to connect with other farmers, share tips, and set up your personal profile!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Clear guest mode to send them back to login
              Hive.box('user_preferences').put('isGuestMode', false);
              // Invalidate auth state to trigger wrapper rebuild
              // But wrapper responds to authStateChanges. 
              // Better to just push replacement to AuthWrapper or just clear state.
              // We'll let main.dart rebuild when user_preferences changes, but it doesn't watch Hive.
              // A simple way is to use Navigator to pushAndRemoveUntil to the AuthWrapper/Login.
              // But we can also just call ref.invalidate on something.
              // Easiest is to pop to root or use Navigator.
              Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final selectedIndex = ref.watch(navigationProvider);
    final themeColor = ref.watch(themeColorProvider);

    final List<Widget> _screens = [
      const HomeScreen(),
      const CommunityScreen(),
      const WeatherScreen(),
      const NewsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
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
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
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
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
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
              // Index 1 = Community, Index 4 = Profile
              if (index == 1 || index == 4) {
                final isGuestMode = Hive.box('user_preferences').get('isGuestMode', defaultValue: false);
                if (isGuestMode) {
                  _showGuestDialog(context, ref);
                  return;
                }
              }
              ref.read(navigationProvider.notifier).state = index;
            },
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.eco_outlined),
                selectedIcon: const Icon(Icons.eco),
                label: strings['nav_crops'] ?? 'Your crops',
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
