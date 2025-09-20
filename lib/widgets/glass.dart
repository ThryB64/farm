import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class Glass extends StatelessWidget {
  const Glass({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.dark = false,
    this.blur = 22,
    this.borderOpacity = .35,
  });

  final Widget? child;
  final EdgeInsets padding;
  final double radius;
  final bool dark;
  final double blur;
  final double borderOpacity;

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
            border: Border.all(color: Colors.white.withOpacity(borderOpacity), width: 1),
            boxShadow: const [
              BoxShadow( // profondeur douce
                offset: Offset(0, 8),
                blurRadius: 24,
                color: Color.fromRGBO(1, 50, 55, 0.18),
              ),
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 6,
                color: Color.fromRGBO(1, 50, 55, 0.12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
