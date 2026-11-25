import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/design/design.dart';
import '../../shared/services/auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final prefs = Hive.box('user_preferences');
    final isGuest = prefs.get('isGuestMode', defaultValue: false) as bool;
    final hasSeenOnboarding = prefs.get('hasSeenOnboarding', defaultValue: false) as bool;
    final authState = ref.read(authStateProvider);
    final isLoggedIn = authState.value != null;

    if (isLoggedIn || isGuest) {
      context.go('/home');
    } else if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 20),
              Text(
                'AgriDX',
                style: AppTextStyles.display1.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Farming Intelligence',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
