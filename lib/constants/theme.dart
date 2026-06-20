import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colors ──────────────────────────────────────────────────────────────────
const Color primaryNavy   = Color(0xFF1B2B4B);
const Color accentOrange  = Color(0xFFF97316);
const Color lightNavy     = Color(0xFF243A63);
const Color bgColor       = Color(0xFFF4F6FA);
const Color surfaceWhite  = Color(0xFFFFFFFF);
const Color borderColor   = Color(0xFFE8EDF3);
const Color textPrimary   = Color(0xFF1B2B4B);
const Color textSecondary = Color(0xFF888888);
const Color textMuted     = Color(0xFFAAAAAA);

const Color successText = Color(0xFF1A8A5A);
const Color successBg   = Color(0xFFEAF8F2);
const Color warningText = Color(0xFFD97706);
const Color warningBg   = Color(0xFFFFF8ED);
const Color dangerText  = Color(0xFFD94A3A);
const Color dangerBg    = Color(0xFFFEF0EF);
const Color infoText    = Color(0xFF185FA5);
const Color infoBg      = Color(0xFFEEF2F8);
const Color purpleText  = Color(0xFF6C5CE7);
const Color purpleBg    = Color(0xFFF0EEFF);

// ── Radius ───────────────────────────────────────────────────────────────────
const double cardRadius      = 12.0;
const double innerCardRadius = 10.0;
const double buttonRadius    = 8.0;
const double pillRadius      = 6.0;

// ── Theme ────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryNavy,
      primary: primaryNavy,
      secondary: accentOrange,
      surface: bgColor,
    ),
    scaffoldBackgroundColor: bgColor,
    useMaterial3: true,
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryNavy,
      foregroundColor: surfaceWhite,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: surfaceWhite,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        minimumSize: const Size.fromHeight(52),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
