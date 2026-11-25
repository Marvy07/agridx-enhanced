import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_shadows.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/design/app_text_styles.dart';

/// Full-bleed photo card with gradient overlay and title.
class AppPhotoCard extends StatelessWidget {
  const AppPhotoCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.height = 180,
    this.onTap,
    this.chip,
    this.borderRadius,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final double height;
  final VoidCallback? onTap;
  final Widget? chip;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.cardRadius;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.backgroundAlt,
                highlightColor: AppColors.surface,
                child: Container(color: AppColors.backgroundAlt),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.primarySurface,
                child: const Icon(Icons.image_outlined, color: AppColors.textHint, size: 40),
              ),
            ),
            // gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppColors.cardOverlay),
              ),
            ),
            // chip top-right
            if (chip != null)
              Positioned(top: 10, right: 10, child: chip!),
            // title bottom
            Positioned(
              left: AppSpacing.cardPadding,
              right: AppSpacing.cardPadding,
              bottom: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
