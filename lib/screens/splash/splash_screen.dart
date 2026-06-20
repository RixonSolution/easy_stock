import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
// import 'package:provider/provider.dart';          // restore when Firebase wired
// import '../../providers/auth_provider.dart';       // restore when Firebase wired

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scaleUp = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _ctrl.forward();

    Timer(const Duration(milliseconds: 2000), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    // TODO: swap back to auth check once Firebase is wired
    // final auth = context.read<AuthProvider>();
    // if (auth.isLoggedIn && auth.verificationStatus == VerificationStatus.approved)
    //   context.go('/home');
    // else
    //   context.go('/onboarding');
    context.go('/home');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo icon — orange rounded square with white "E"
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: accentOrange,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: accentOrange.withValues(alpha: 0.40),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'E',
                    style: GoogleFonts.inter(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: surfaceWhite,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // Wordmark: bold "Easy" + light "Stock"
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Easy',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: surfaceWhite,
                        ),
                      ),
                      TextSpan(
                        text: 'Stock',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: surfaceWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline matching brand: "PAINT & PLY DISTRIBUTION"
                Text(
                  'PAINT & PLY DISTRIBUTION',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white38,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 48),
                // Loading dots
                const _DotIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatefulWidget {
  const _DotIndicator();

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (mounted) {
            setState(() => _active = (_active + 1) % 3);
            _ctrl.forward(from: 0);
          }
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
      children: List.generate(3, (i) {
        final isActive = i == _active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? accentOrange : Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
