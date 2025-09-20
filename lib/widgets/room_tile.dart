import 'package:flutter/material.dart';
import 'glass.dart';
import '../theme/theme.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({Key? key, required this.title, required this.photo, this.meta}) : super(key: key);
  final String title;
  final ImageProvider photo;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Photo
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: photo, fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(.05), BlendMode.srcOver)),
        ),
      ),
      // Halo doux derrière le glass (glow primary)
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              colors: [AppColors.coral.withOpacity(.12), AppColors.salmon.withOpacity(.10), Colors.transparent],
              radius: 1.0,
              stops: const [.0, .35, 1],
              center: Alignment.topLeft,
            ),
          ),
        ),
      ),
      // Bandeau bas glass
      Positioned(
        left: 10, right: 10, bottom: 10,
        child: Glass(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16), overflow: TextOverflow.ellipsis),
                  if (meta != null)
                    Text(meta!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
          dark: true,
          radius: 20,
        ),
      ),
    ]);
  }
}
