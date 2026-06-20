import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';
import '../distributors/distributor_detail_screen.dart';

// ── Mock data ──────────────────────────────────────────────────────────────
const _shopName  = 'Al-Kareem Paint Store';
const _ownerName = 'Ammar';

const _distributors = [
  _DistData('Pak Paints',     'Lahore',    Color(0xFF185FA5), Color(0xFFEEF2F8), 'PP', 'Dulux · ICI · Jotun',    'approved'),
  _DistData('Royal Colors',   'Karachi',   Color(0xFF6C5CE7), Color(0xFFF0EEFF), 'RC', 'Berger · Nippon',        'approved'),
  _DistData('Master Ply',     'Faisalabad',Color(0xFF1A8A5A), Color(0xFFEAF8F2), 'MP', 'Century · Green Ply',    'approved'),
  _DistData('National Dist.', 'Multan',    Color(0xFFD97706), Color(0xFFFFF8ED), 'ND', 'ICI · Berger',           'requested'),
];

const _recentOrders = [
  _OrderData('ORD-2401', 'Pak Paints', 'Rs. 12,400', 'approved',  '2 days ago', 4),
  _OrderData('ORD-2398', 'Royal Colors', 'Rs. 8,750', 'requested', '4 days ago', 2),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header ──────────────────────────────────────────────────
          _NavyHeader(greeting: _greeting(), shopName: _shopName),

          // ── Scrollable body ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row — IntrinsicHeight ensures all cards are equal height
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.receipt_long_rounded,
                            value: '3',
                            label: 'Active Orders',
                            iconColor: infoText,
                            iconBg: infoBg,
                            onTap: () => context.go('/orders', extra: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.store_rounded,
                            value: '4',
                            label: 'Distributors',
                            iconColor: purpleText,
                            iconBg: purpleBg,
                            onTap: () => context.go('/distributors'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_rounded,
                            value: '18',
                            label: 'Completed',
                            iconColor: successText,
                            iconBg: successBg,
                            onTap: () => context.go('/orders', extra: 3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── My Distributors ──────────────────────────────────────
                  _SectionHeader(
                    title: 'My Distributors',
                    actionLabel: 'See all',
                    onAction: () => context.go('/distributors'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 96,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ..._distributors.map((d) => _DistributorTile(data: d)),
                        _AddNewTile(onTap: () => context.go('/distributors')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Recent Orders ────────────────────────────────────────
                  _SectionHeader(
                    title: 'Recent Orders',
                    actionLabel: 'View all',
                    onAction: () => context.go('/orders'),
                  ),
                  const SizedBox(height: 14),
                  ..._recentOrders.map((o) => _OrderCard(order: o)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// ── Navy header ─────────────────────────────────────────────────────────────
class _NavyHeader extends StatelessWidget {
  const _NavyHeader({required this.greeting, required this.shopName});
  final String greeting;
  final String shopName;

  // Unread count — kept as a const here; will update from provider when Firebase wired
  static const _unreadCount = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $_ownerName 👋',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shopName,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        // Unread badge
                        if (_unreadCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: _unreadCount > 9
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2)
                                  : null,
                              width: _unreadCount > 9 ? null : 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: accentOrange,
                                shape: _unreadCount > 9
                                    ? BoxShape.rectangle
                                    : BoxShape.circle,
                                borderRadius: _unreadCount > 9
                                    ? BorderRadius.circular(9)
                                    : null,
                                border: Border.all(
                                    color: primaryNavy, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$_unreadCount',
                                style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar — tapping pushes the search screen
              GestureDetector(
                onTap: () => context.push('/search'),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Search products, distributors...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: accentOrange,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Distributor tile ─────────────────────────────────────────────────────────
class _DistributorTile extends StatelessWidget {
  const _DistributorTile({required this.data});
  final _DistData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/distributors/${Uri.encodeComponent(data.name)}',
        extra: DistributorArg(
          name: data.name,
          city: data.city,
          brands: data.brands,
          initials: data.initials,
          fg: data.fg,
          bg: data.bg,
          linkStatus: data.linkStatus,
        ),
      ),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DistributorAvatar(
              initials: data.initials,
              bg: data.bg,
              fg: data.fg,
              size: 52,
            ),
            const SizedBox(height: 6),
            Text(
              data.name,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add new tile ──────────────────────────────────────────────────────────────
class _AddNewTile extends StatelessWidget {
  const _AddNewTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: accentOrange,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add new',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: accentOrange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _OrderData order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}/tracking'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Distributor avatar — first two letters
                DistributorAvatar(
                  initials: order.distributor.substring(0, 2),
                  bg: infoBg,
                  fg: infoText,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.distributor,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(order.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),
            Row(
              children: [
                _Meta(
                  icon: Icons.inventory_2_outlined,
                  label: '${order.itemCount} items',
                ),
                const SizedBox(width: 16),
                _Meta(
                  icon: Icons.access_time_rounded,
                  label: order.date,
                ),
                const Spacer(),
                Text(
                  order.total,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        ),
      ],
    );
  }
}

// ── Data models (mock) ────────────────────────────────────────────────────────
class _DistData {
  const _DistData(this.name, this.city, this.fg, this.bg, this.initials,
      this.brands, this.linkStatus);
  final String name, city, initials, brands, linkStatus;
  final Color fg, bg;
}

class _OrderData {
  const _OrderData(
      this.id, this.distributor, this.total, this.status, this.date, this.itemCount);
  final String id;
  final String distributor;
  final String total;
  final String status;
  final String date;
  final int itemCount;
}
