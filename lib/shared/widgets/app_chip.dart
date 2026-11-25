import 'package:flutter/material.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: textColor ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class AppSeverityChip extends StatelessWidget {
  const AppSeverityChip({super.key, required this.severity});
  final String severity;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (severity.toLowerCase()) {
      'low' => (AppColors.severityLow, 'Low'),
      'medium' => (AppColors.severityMedium, 'Medium'),
      'high' => (AppColors.severityHigh, 'High'),
      'critical' => (AppColors.severityCritical, 'Critical'),
      _ => (AppColors.textHint, severity),
    };

    return AppChip(
      label: label,
      color: color.withOpacity(0.12),
      textColor: color,
    );
  }
}
