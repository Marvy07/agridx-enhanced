import 'package:flutter/material.dart';
import '../../core/design/design.dart';
import '../../shared/widgets/widgets.dart';

class DetectionResultScreen extends StatelessWidget {
  const DetectionResultScreen({super.key, this.result});
  final Map<String, dynamic>? result;

  @override
  Widget build(BuildContext context) {
    final disease = result?['disease_name'] as String? ?? 'Early Blight';
    final confidence = ((result?['confidence'] as double? ?? 0.87) * 100).toStringAsFixed(0);
    final severity = result?['severity'] as String? ?? 'medium';
    final description = result?['description'] as String? ??
        'Early blight is a fungal disease caused by Alternaria solani. It appears as dark, concentric rings on older leaves, often surrounded by a yellow halo.';
    final treatments = (result?['treatments'] as List<dynamic>?) ??
        ['Remove and destroy infected leaves', 'Apply copper-based fungicide', 'Ensure proper plant spacing for air circulation', 'Water at the base, avoid wetting foliage'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detection Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.coronavirus_rounded, color: AppColors.warning, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(disease, style: AppTextStyles.h3),
                            const SizedBox(height: 2),
                            Text('$confidence% confidence', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      AppSeverityChip(severity: severity),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text('About this disease', style: AppTextStyles.h4),
                  const SizedBox(height: 6),
                  Text(description, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Recommended Treatments', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            ...treatments.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppSurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t.toString(), style: AppTextStyles.bodyMedium)),
                  ],
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Save to My Diagnoses', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
