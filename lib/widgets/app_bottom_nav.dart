import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/auth_provider.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  // -1 means no tab is active (used on the pending screen)
  final int currentIndex;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home', '/home'),
    (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders',
        '/orders'),
    (Icons.store_rounded, Icons.store_outlined, 'Wholesalers', '/distributors'),
    (Icons.person_rounded, Icons.person_outlined, 'Profile', '/profile'),
  ];

  void _showLockedSheet(BuildContext context, bool isPending) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LockedSheet(isPending: isPending),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isPending = auth.isPending;
    final isLocked = !auth.canAccess; // any tab except Profile is locked when not fully active

    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final (activeIcon, inactiveIcon, label, route) = _items[i];
              final isActive = i == currentIndex;
              // Profile (index 3) is always accessible
              final isTabLocked = isLocked && i != 3;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isTabLocked) {
                      _showLockedSheet(context, isPending);
                      return;
                    }
                    if (!isActive) context.go(route);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? activeIcon : inactiveIcon,
                            color: isTabLocked
                                ? textMuted
                                : isActive
                                    ? accentOrange
                                    : textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isTabLocked
                                  ? textMuted
                                  : isActive
                                      ? accentOrange
                                      : textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (isTabLocked)
                        Positioned(
                          top: -2,
                          right: 10,
                          child: Icon(Icons.lock_rounded,
                              size: 9, color: textMuted),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet shown when a locked tab is tapped ────────────────────────────
class _LockedSheet extends StatelessWidget {
  const _LockedSheet({required this.isPending});
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 28),

          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: warningBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded,
                color: warningText, size: 30),
          ),

          const SizedBox(height: 18),

          Text(
            isPending ? 'Account Under Review' : 'Subscription Required',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Text(
            isPending
                ? 'Your account is under review. You\'ll get full access once approved by our team — usually within 24–48 hours.'
                : 'Subscribe to a plan to unlock this feature and start placing orders.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          if (!isPending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.go('/profile/subscription');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  'Choose a Plan',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.pop();
                  context.push('/profile/support');
                },
                icon: const Icon(Icons.support_agent_rounded, size: 18),
                label: Text(
                  'Contact Support',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: primaryNavy,
                  side: const BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
