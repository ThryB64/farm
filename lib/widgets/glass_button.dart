import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

/// Bouton avec effet glassmorphism
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isSecondary;
  final bool isTertiary;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;

  const GlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isSecondary = false,
    this.isTertiary = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isDisabled && !isLoading;
    
    return Container(
      width: width,
      height: height ?? AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: isPrimary ? AppShadows.buttonShadows : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: _getDecoration(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    if (isPrimary) {
      return BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      );
    } else if (isSecondary) {
      return BoxDecoration(
        color: AppColors.glassLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.glassBorder),
      );
    } else if (isTertiary) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      );
    }
    
    return BoxDecoration(
      color: AppColors.glassLight,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      border: Border.all(color: AppColors.glassBorder),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final textColor = isPrimary ? Colors.white : AppColors.deepNavy;
    final textStyle = isTertiary 
        ? AppTypography.bodyStyle.copyWith(color: textColor.withOpacity(0.8))
        : AppTypography.bodyStyle.copyWith(color: textColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSpacing.iconSize, color: textColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(text, style: textStyle),
      ],
    );
  }
}

/// Bouton FAB avec effet glassmorphism
class GlassFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const GlassFab({
    Key? key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(
          isExtended ? AppSpacing.radiusMd : AppSpacing.radiusXl,
        ),
        boxShadow: AppShadows.fabShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(
            isExtended ? AppSpacing.radiusMd : AppSpacing.radiusXl,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExtended ? AppSpacing.xl : AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: isExtended
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: AppSpacing.iconSize),
                      if (label != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          label!,
                          style: AppTypography.whiteStyle,
                        ),
                      ],
                    ],
                  )
                : Icon(icon, color: Colors.white, size: AppSpacing.iconSize),
          ),
        ),
      ),
    );
  }
}
