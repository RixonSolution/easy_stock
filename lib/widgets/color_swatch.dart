import 'package:flutter/material.dart';
import '../constants/theme.dart';

class ColorSwatch extends StatelessWidget {
  const ColorSwatch({
    super.key,
    required this.hex,
    this.size = 40,
    this.selected = false,
    this.disabled = false,
  });

  final String hex;
  final double size;
  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color = _fromHex(hex);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: selected
            ? Border.all(color: accentOrange, width: 2.5)
            : Border.all(color: borderColor),
      ),
      child: disabled
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(size * 0.2),
                  ),
                ),
                Icon(Icons.close_rounded,
                    size: size * 0.45, color: Colors.white70),
              ],
            )
          : null,
    );
  }

  static Color _fromHex(String hex) {
    final h = hex.replaceAll('#', '').padLeft(8, 'FF');
    return Color(int.parse(h, radix: 16));
  }
}
