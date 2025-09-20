import 'package:flutter/material.dart';
import 'glass.dart';
import '../theme/theme.dart';

class DeviceChip extends StatelessWidget {
  const DeviceChip({Key? key, required this.icon, required this.label, this.active = false}) : super(key: key);
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.white : AppColors.navy.withOpacity(.7)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : AppColors.navy.withOpacity(.8))),
      ],
    );

    if (!active) {
      return Glass(
        radius: 28,
        padding: const EdgeInsets.all(12),
        child: SizedBox(width: 72, height: 72, child: content),
      );
    }

    // actif → anneau gradient + glow
    return Container(
      width: 76, height: 76,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: primaryGradient,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(offset: Offset(0, 8), blurRadius: 20, color: Color.fromRGBO(1, 50, 55, 0.22))],
      ),
      child: Glass(
        radius: 38,
        padding: const EdgeInsets.all(10),
        dark: true,
        child: content,
      ),
    );
  }
}
