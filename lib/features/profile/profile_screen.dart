import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/design.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const AppEmptyState(
          icon: Icons.person_outline_rounded,
          title: 'Could not load profile',
          message: 'Try signing in again.',
        ),
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Avatar + name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                          ? Text(
                              (user?.displayName?.isNotEmpty == true
                                  ? user!.displayName![0]
                                  : user?.email?.isNotEmpty == true
                                      ? user!.email![0]
                                      : '?')
                                  .toUpperCase(),
                              style: AppTextStyles.h2.copyWith(color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Farmer',
                            style: AppTextStyles.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'Guest mode',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          AppChip(
                            label: 'Free Plan',
                            color: Colors.white.withOpacity(0.2),
                            textColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Menu sections
              _ProfileSection(
                title: 'Activity',
                items: [
                  _ProfileItem(
                    icon: Icons.history_rounded,
                    label: 'My Diagnoses',
                    onTap: () => context.push('/profile/diagnoses'),
                  ),
                  _ProfileItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => context.push('/profile/notifications'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: 'Subscription',
                items: [
                  _ProfileItem(
                    icon: Icons.star_outline_rounded,
                    label: 'Upgrade to Premium',
                    badge: 'Free',
                    onTap: () => context.push('/profile/subscription'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: 'Settings',
                items: [
                  _ProfileItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'AI Assistant',
                    onTap: () => context.push('/profile/chat'),
                  ),
                  _ProfileItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push('/profile/settings'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileSection(
                title: '',
                items: [
                  _ProfileItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: AppColors.error,
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.items});
  final String title;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
        ],
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (item.color ?? AppColors.primary).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color ?? AppColors.primary,
                        size: 18,
                      ),
                    ),
                    title: Text(item.label, style: AppTextStyles.labelLarge),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.badge != null)
                          AppChip(label: item.badge!),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textHint, size: 20),
                      ],
                    ),
                    onTap: item.onTap,
                  ),
                  if (i < items.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem {
  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;
  final Color? color;
}
