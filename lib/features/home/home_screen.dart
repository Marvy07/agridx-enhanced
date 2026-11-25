import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/design.dart';
import '../../shared/widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _HomeAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList.list(
              children: [
                _QuickDetectBanner(),
                const SizedBox(height: AppSpacing.sectionSpacing),
                AppSectionHeader(
                  title: 'Your Crops',
                  actionLabel: 'See all',
                  onAction: () => context.go('/library'),
                ),
                const SizedBox(height: AppSpacing.md),
                _CropCarousel(),
                const SizedBox(height: AppSpacing.sectionSpacing),
                AppSectionHeader(
                  title: 'Animal Care',
                  actionLabel: 'See all',
                  onAction: () => context.go('/animals'),
                ),
                const SizedBox(height: AppSpacing.md),
                _AnimalRow(),
                const SizedBox(height: AppSpacing.sectionSpacing),
                AppSectionHeader(title: 'Community'),
                const SizedBox(height: AppSpacing.md),
                _CommunityPreview(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('AgriDX', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: () => context.push('/profile/notifications'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _QuickDetectBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppShadows.button,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detect Disease',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Take a photo of your crop or animal to get an instant AI diagnosis.',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: () => context.go('/scan/plant'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Scan Now',
                                style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search_rounded, size: 36, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCarousel extends StatelessWidget {
  static const _crops = [
    (name: 'Maize', image: '', sub: '12 diseases'),
    (name: 'Tomato', image: '', sub: '8 diseases'),
    (name: 'Cassava', image: '', sub: '6 diseases'),
    (name: 'Rice', image: '', sub: '10 diseases'),
    (name: 'Banana', image: '', sub: '5 diseases'),
  ];

  static final _images = [
    AppImages.cropMaize,
    AppImages.cropTomato,
    AppImages.cropCassava,
    AppImages.cropRice,
    AppImages.cropBanana,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _crops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final crop = _crops[i];
          return SizedBox(
            width: 130,
            child: AppPhotoCard(
              imageUrl: _images[i],
              title: crop.name,
              subtitle: crop.sub,
              height: 160,
              onTap: () => context.go('/library/${crop.name.toLowerCase()}'),
            ),
          );
        },
      ),
    );
  }
}

class _AnimalRow extends StatelessWidget {
  static const _animals = [
    (name: 'Cattle', image: ''),
    (name: 'Poultry', image: ''),
    (name: 'Goats', image: ''),
  ];

  static final _images = [
    AppImages.animalCattle,
    AppImages.animalPoultry,
    AppImages.animalGoat,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_animals.length, (i) {
        final animal = _animals[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _animals.length - 1 ? 10 : 0),
            child: AppPhotoCard(
              imageUrl: _images[i],
              title: animal.name,
              height: 110,
              borderRadius: 12,
              onTap: () => context.go('/animals/${animal.name.toLowerCase()}'),
            ),
          ),
        );
      }),
    );
  }
}

class _CommunityPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: () => context.go('/community'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join the community', style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  'Ask questions, share tips, and get answers from other farmers.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}
