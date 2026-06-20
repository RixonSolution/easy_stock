import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    this.compact = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 32 : 40,
              height: compact ? 32 : 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: compact ? 18 : 22),
            ),
            SizedBox(height: compact ? 8 : 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: compact ? 11 : 12,
                color: textSecondary,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
