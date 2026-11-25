import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/design.dart';
import '../../shared/widgets/widgets.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detect Disease')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to diagnose?',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a clear photo of the affected plant or animal for best results.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            _DetectOptionCard(
              title: 'Plant / Crop',
              subtitle: '200+ diseases detected across 50+ crops',
              icon: Icons.local_florist_rounded,
              color: AppColors.primary,
              imageUrl: AppImages.scanLeaf,
              onTap: () => context.push('/scan/plant/result'),
            ),
            const SizedBox(height: AppSpacing.md),
            _DetectOptionCard(
              title: 'Animal',
              subtitle: 'Coming soon — cattle, poultry, goats and more',
              icon: Icons.pets_rounded,
              color: AppColors.textSecondary,
              imageUrl: AppImages.animalCattle,
              onTap: null,
              badge: 'Coming Soon',
            ),
            const SizedBox(height: AppSpacing.md),
            _DetectOptionCard(
              title: 'Symptom Checker',
              subtitle: 'Describe symptoms in text for a differential diagnosis',
              icon: Icons.medical_services_outlined,
              color: AppColors.info,
              imageUrl: AppImages.heroFarmer,
              onTap: () => context.push('/scan/plant/symptom'),
              badge: 'Beta',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectOptionCard extends StatelessWidget {
  const _DetectOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1.0,
      child: AppPhotoCard(
        imageUrl: imageUrl,
        title: title,
        subtitle: subtitle,
        height: 150,
        onTap: onTap,
        chip: badge != null
            ? AppChip(
                label: badge!,
                color: Colors.white.withOpacity(0.2),
                textColor: Colors.white,
              )
            : AppChip(
                label: 'Tap to scan',
                color: AppColors.primary.withOpacity(0.8),
                textColor: Colors.white,
                icon: Icons.camera_alt_rounded,
              ),
      ),
    );
  }
}
