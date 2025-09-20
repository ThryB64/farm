import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';

/// Chip avec effet glassmorphism
class GlassChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GlassChip({
    Key? key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.isActive = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? AppSpacing.chipSize,
      height: height ?? AppSpacing.chipSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: isSelected ? AppShadows.glassShadows : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: _getBorderColor(),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: AppSpacing.iconSize,
                          color: _getTextColor(),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: _getTextColor(),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return AppColors.glassLight;
    }
    if (isActive) {
      return AppColors.glassLight;
    }
    return backgroundColor ?? AppColors.glassLight;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return AppColors.coral;
    }
    if (isActive) {
      return AppColors.glassBorder;
    }
    return AppColors.glassBorder;
  }

  Color _getTextColor() {
    if (isSelected || isActive) {
      return AppColors.deepNavy;
    }
    return textColor ?? AppColors.navy70;
  }
}

/// Chip pour les appareils/contrôles
class DeviceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOn;
  final String? status;
  final VoidCallback? onTap;
  final Color? activeColor;

  const DeviceChip({
    Key? key,
    required this.label,
    required this.icon,
    this.isOn = false,
    this.status,
    this.onTap,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassChip(
      label: label,
      icon: icon,
      isSelected: isOn,
      isActive: isOn,
      onTap: onTap,
      textColor: isOn ? AppColors.deepNavy : AppColors.navy50,
    );
  }
}

/// Chip pour les variétés
class VarietyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const VarietyChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: isSelected ? AppShadows.glassShadows : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.glassLight : AppColors.glassLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.coral : AppColors.glassBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.deepNavy : AppColors.navy70,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
