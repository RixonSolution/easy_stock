import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';

class RegisterPendingScreen extends StatelessWidget {
  const RegisterPendingScreen({super.key, required this.referenceNumber});
  final String referenceNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green circle with clock icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: successBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    size: 48,
                    color: successText,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Application Submitted!',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Your shop registration is under review. We\'ll notify you once it\'s approved — usually within 24–48 hours.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Reference number pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: warningBg,
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: warningText.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          size: 16, color: warningText),
                      const SizedBox(width: 8),
                      Text(
                        'Reference  ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: warningText,
                        ),
                      ),
                      Text(
                        '#$referenceNumber',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: warningText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // What happens next card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens next?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        (Icons.search_rounded,
                            'Our team reviews your documents'),
                        (Icons.notifications_outlined,
                            'You\'ll receive a notification with the result'),
                        (Icons.store_rounded,
                            'Once approved, you can connect with distributors'),
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(item.$1,
                                      size: 16, color: textSecondary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.$2,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () => context.go('/splash'),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
