import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class Glass extends StatelessWidget {
  const Glass({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.dark = false,
    this.blur = 22,
    this.borderOpacity = 0.35,
    this.saturation = 1.4,
  });

  final Widget? child;
  final EdgeInsets padding;
  final double radius;
  final bool dark;
  final double blur;
  final double borderOpacity;
  final double saturation;

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? const Color.fromRGBO(1, 50, 55, 0.35)
        : const Color.fromRGBO(255, 255, 255, 0.16);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
            boxShadow: AppShadows.glass,
          ),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              saturation, 0, 0, 0, 0,
              0, saturation, 0, 0, 0,
              0, 0, saturation, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.dark = false,
    this.onTap,
  });

  final Widget? child;
  final EdgeInsets padding;
  final double radius;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Glass(
          padding: padding,
          radius: radius,
          dark: dark,
          child: child,
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  const GlassButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
    this.gradient = false,
    this.radius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool gradient;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (gradient) {
      return InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: AppShadows.button,
          ),
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 1,
          ),
          boxShadow: AppShadows.card,
        ),
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.navy, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
