import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DistributorAvatar extends StatelessWidget {
  const DistributorAvatar({
    super.key,
    required this.initials,
    required this.bg,
    required this.fg,
    this.size = 44,
  });

  final String initials;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
