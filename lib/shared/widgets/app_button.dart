import 'package:flutter/material.dart';
import '../../core/design/app_colors.dart';
import '../../core/design/app_shadows.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.buttonLarge.copyWith(color: _foregroundColor)),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            boxShadow: onPressed != null ? AppShadows.button : [],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              onTap: isLoading ? null : onPressed,
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ),
        ),
      AppButtonVariant.secondary => Container(
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              onTap: isLoading ? null : onPressed,
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ),
        ),
      AppButtonVariant.outline => Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              onTap: isLoading ? null : onPressed,
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ),
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color get _foregroundColor => switch (variant) {
    AppButtonVariant.primary => Colors.white,
    AppButtonVariant.secondary => AppColors.primary,
    AppButtonVariant.outline => AppColors.primary,
    AppButtonVariant.ghost => AppColors.primary,
  };
}
