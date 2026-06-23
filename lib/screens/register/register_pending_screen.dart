import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class RegisterPendingScreen extends StatefulWidget {
  const RegisterPendingScreen({super.key, required this.referenceNumber});
  final String referenceNumber;

  @override
  State<RegisterPendingScreen> createState() => _RegisterPendingScreenState();
}

class _RegisterPendingScreenState extends State<RegisterPendingScreen> {
  StreamSubscription<DocumentSnapshot>? _sub;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _listenForApproval();
  }

  void _listenForApproval() {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _sub = FirebaseFirestore.instance
        .collection('retailers')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final status = snap.data()?['verificationStatus'] as String?;
      if (status == 'approved') {
        // Refresh AuthProvider then navigate after a short delay (show success UI)
        context.read<AuthProvider>().refreshProfile();
        _navTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) context.go('/profile/subscription');
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isApproved = auth.verificationStatus == VerificationStatus.approved;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isApproved
                  ? _ApprovedContent(key: const ValueKey('approved'))
                  : _PendingContent(
                      key: const ValueKey('pending'),
                      referenceNumber: widget.referenceNumber,
                    ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: -1),
    );
  }
}

// ── Pending state ─────────────────────────────────────────────────────────────
class _PendingContent extends StatelessWidget {
  const _PendingContent({super.key, required this.referenceNumber});
  final String referenceNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clock icon in green circle
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
          'Your shop registration is under review. We\'ll notify you once it\'s approved.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Animated review-in-progress indicator
        const _ReviewingIndicator(),

        const SizedBox(height: 24),

        // Reference number pill
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: warningBg,
            borderRadius: BorderRadius.circular(cardRadius),
            border:
                Border.all(color: warningText.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  size: 16, color: warningText),
              const SizedBox(width: 8),
              Text(
                'Reference  ',
                style:
                    GoogleFonts.inter(fontSize: 13, color: warningText),
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

        const SizedBox(height: 36),

        // What happens next
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
                (Icons.search_rounded, 'Our team reviews your documents'),
                (Icons.notifications_outlined,
                    'You\'ll receive a notification with the result'),
                (Icons.workspace_premium_rounded,
                    'Once approved, choose a plan and start ordering'),
              ].map(
                (item) => Padding(
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
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Contact Support
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/profile/support'),
            icon: const Icon(Icons.support_agent_rounded, size: 18),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: primaryNavy,
              side: const BorderSide(color: borderColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated "reviewing" dots indicator ───────────────────────────────────────
class _ReviewingIndicator extends StatefulWidget {
  const _ReviewingIndicator();

  @override
  State<_ReviewingIndicator> createState() =>
      _ReviewingIndicatorState();
}

class _ReviewingIndicatorState extends State<_ReviewingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _dot = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _dot = (_dot + 1) % 3);
          _ctrl.forward(from: 0);
        }
      });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reviewing your application',
          style: GoogleFonts.inter(fontSize: 13, color: textMuted),
        ),
        const SizedBox(width: 4),
        ...List.generate(3, (i) {
          final active = i == _dot;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: active ? 7 : 5,
            height: active ? 7 : 5,
            decoration: BoxDecoration(
              color: active ? accentOrange : textMuted.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          );
        }),
      ],
    );
  }
}

// ── Approved state ────────────────────────────────────────────────────────────
class _ApprovedContent extends StatelessWidget {
  const _ApprovedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checkmark in green circle
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: successBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 52,
            color: successText,
          ),
        ),

        const SizedBox(height: 28),

        Text(
          'Account Approved!',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Your shop has been verified. Taking you into the app…',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Success card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: successBg,
            borderRadius: BorderRadius.circular(cardRadius),
            border:
                Border.all(color: successText.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: successText, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification complete — setting up your account',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: successText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Loading spinner while auto-activating
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
          ),
        ),
      ],
    );
  }
}
