import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.title,
    required this.photo,
    this.meta,
    this.onTap,
    this.active = false,
  });

  final String title;
  final ImageProvider photo;
  final String? meta;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Photo de fond
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              image: DecorationImage(
                image: photo,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.05),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          
          // Halo doux derrière le glass (glow primary)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: AppGradients.backgroundGlow,
              ),
            ),
          ),
          
          // Bandeau bas glass
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Glass(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              dark: true,
              radius: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta != null)
                          Text(
                            meta!,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Indicateur actif
          if (active)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.button,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DeviceChip extends StatelessWidget {
  const DeviceChip({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: active ? Colors.white : AppColors.navy.withOpacity(0.7),
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.navy.withOpacity(0.8),
          ),
        ),
      ],
    );

    if (!active) {
      return GestureDetector(
        onTap: onTap,
        child: Glass(
          radius: 28,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 72,
            height: 72,
            child: content,
          ),
        ),
      );
    }

    // Actif → anneau gradient + glow
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          shape: BoxShape.circle,
          boxShadow: AppShadows.button,
        ),
        child: Glass(
          radius: 38,
          padding: const EdgeInsets.all(10),
          dark: true,
          child: content,
        ),
      ),
    );
  }
}
