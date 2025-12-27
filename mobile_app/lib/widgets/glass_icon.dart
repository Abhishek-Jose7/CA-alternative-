import 'package:flutter/material.dart';

class GlassIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const GlassIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Semi-transparent background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color, // Vibrant solid shape on top
          size: iconSize,
        ),
      ),
    );
  }
}
