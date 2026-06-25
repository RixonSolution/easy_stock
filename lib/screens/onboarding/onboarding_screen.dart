import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.store_rounded,
      iconBg: Color(0xFFEEF2F8),
      iconColor: Color(0xFF185FA5),
      title: 'Connect with Wholesalers',
      body:
          'Discover and connect with trusted wholesalers in your area. Browse their full product catalogue anytime.',
    ),
    _SlideData(
      icon: Icons.inventory_2_rounded,
      iconBg: Color(0xFFFFF8ED),
      iconColor: Color(0xFFD97706),
      title: 'Order Stock with Ease',
      body:
          'Select colors, sizes and quantities in seconds. Track every order from placement to delivery.',
    ),
    _SlideData(
      icon: Icons.trending_up_rounded,
      iconBg: Color(0xFFEAF8F2),
      iconColor: Color(0xFF1A8A5A),
      title: 'Grow Your Business',
      body:
          'Stay on top of stock levels, order history and wholesaler relationships — all in one place.',
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() => context.go('/login');

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),

            // Dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? accentOrange : borderColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(isLast ? 'Get Started' : 'Next'),
              ),
            ),

            const SizedBox(height: 16),

            // Sign in link
            GestureDetector(
              onTap: () => context.go('/login'),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already have an account? ',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: textSecondary),
                    ),
                    TextSpan(
                      text: 'Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: slide.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 48, color: slide.iconColor),
          ),

          const SizedBox(height: 40),

          Text(
            slide.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          Text(
            slide.body,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
}
