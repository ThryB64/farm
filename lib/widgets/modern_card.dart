import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;
  final double? borderRadius;
  final Gradient? gradient;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.shadow,
    this.borderRadius,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.background(context),
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
        boxShadow: shadow ?? AppTheme.cardShadows(context),
        gradient: gradient,
      ),
      child: Material(
        color: AppTheme.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
          child: Padding(
            padding: padding ?? AppTheme.padding(AppTheme.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Gradient gradient;
  final double? borderRadius;

  const GradientCard({
    Key? key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      gradient: gradient,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.textTheme(context).bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: AppTheme.spacingXS),
                      Text(
                        subtitle!,
                        style: AppTheme.textTheme(context).bodySmall?.copyWith(
                          color: AppTheme.textLight(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            value,
                          style: AppTheme.textTheme(context).headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  const MenuCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppTheme.padding(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Icon(
                icon,
                size: AppTheme.iconSizeXL,
                color: color,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: AppTheme.textTheme(context).bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppTheme.spacingXS),
              Text(
                subtitle!,
                style: AppTheme.textTheme(context).bodySmall?.copyWith(
                  color: AppTheme.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
