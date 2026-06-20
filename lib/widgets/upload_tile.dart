import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';

class UploadTile extends StatelessWidget {
  const UploadTile({
    super.key,
    required this.label,
    required this.sub,
    required this.done,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: done ? successText : borderColor,
            width: done ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: done ? successBg : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                done ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                color: done ? successText : textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              done ? Icons.check_circle : Icons.chevron_right_rounded,
              color: done ? successText : textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
