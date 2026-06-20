import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';
import '../widgets/app_bottom_nav.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.navIndex,
  });

  final String title;
  final int navIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(Icons.construction_rounded,
                  size: 36, color: textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming soon',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This screen is being built.',
              style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: navIndex),
    );
  }
}
