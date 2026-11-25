import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_shadows.dart';
import '../../core/design/app_text_styles.dart';

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.activeIcon, required this.path});
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}

const _navItems = [
  _NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, path: '/home'),
  _NavItem(label: 'Detect', icon: Icons.camera_alt_outlined, activeIcon: Icons.camera_alt_rounded, path: '/scan/plant'),
  _NavItem(label: 'Library', icon: Icons.local_florist_outlined, activeIcon: Icons.local_florist_rounded, path: '/library'),
  _NavItem(label: 'Animals', icon: Icons.pets_outlined, activeIcon: Icons.pets_rounded, path: '/animals'),
  _NavItem(label: 'Community', icon: Icons.forum_outlined, activeIcon: Icons.forum_rounded, path: '/community'),
  _NavItem(label: 'Weather', icon: Icons.cloud_outlined, activeIcon: Icons.cloud_rounded, path: '/weather'),
  _NavItem(label: 'News', icon: Icons.newspaper_outlined, activeIcon: Icons.newspaper_rounded, path: '/news'),
  _NavItem(label: 'Profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, path: '/profile'),
];

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.child});
  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.bottomBar,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(item.path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive ? AppColors.primary : AppColors.textHint,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.caption.copyWith(
                            color: isActive ? AppColors.primary : AppColors.textHint,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
