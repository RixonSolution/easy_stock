import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_pill.dart';
import 'distributor_detail_screen.dart';

// ── Mock data ────────────────────────────────────────────────────────────────
const _discover = [
  _Dist('ColorMax Distributors', 'Islamabad', 'Dulux · Nippon · Asian',
      Color(0xFF1A8A5A), Color(0xFFEAF8F2), 'CD', 'none'),
  _Dist('Apex Paint Supplies', 'Rawalpindi', 'Berger · Kansai',
      Color(0xFFD97706), Color(0xFFFFF8ED), 'AP', 'none'),
  _Dist('Prime Colors Co.', 'Lahore', 'ICI · Jotun · Sika',
      Color(0xFF6C5CE7), Color(0xFFF0EEFF), 'PC', 'requested'),
  _Dist('Al-Amin Trading', 'Karachi', 'Nippon · Dulux',
      Color(0xFF185FA5), Color(0xFFEEF2F8), 'AT', 'none'),
  _Dist('Super Ply Works', 'Multan', 'Century · Green Ply',
      Color(0xFFD94A3A), Color(0xFFFEF0EF), 'SP', 'none'),
];

const _mine = [
  _Dist('Pak Paints', 'Lahore', 'Dulux · ICI · Jotun',
      Color(0xFF185FA5), Color(0xFFEEF2F8), 'PP', 'approved'),
  _Dist('Royal Colors', 'Karachi', 'Berger · Nippon',
      Color(0xFF6C5CE7), Color(0xFFF0EEFF), 'RC', 'approved'),
  _Dist('Master Ply', 'Faisalabad', 'Century · Green Ply · Action',
      Color(0xFF1A8A5A), Color(0xFFEAF8F2), 'MP', 'approved'),
  _Dist('National Dist.', 'Multan', 'ICI · Berger',
      Color(0xFFD97706), Color(0xFFFFF8ED), 'ND', 'requested'),
];

class DistributorConnectionsScreen extends StatefulWidget {
  const DistributorConnectionsScreen({super.key});

  @override
  State<DistributorConnectionsScreen> createState() =>
      _DistributorConnectionsScreenState();
}

class _DistributorConnectionsScreenState
    extends State<DistributorConnectionsScreen> {
  int _tab = 0;
  String _search = '';
  final Set<String> _pendingConnect = {};

  List<_Dist> get _discoverFiltered {
    if (_search.isEmpty) return _discover;
    final q = _search.toLowerCase();
    return _discover
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.city.toLowerCase().contains(q) ||
            d.brands.toLowerCase().contains(q))
        .toList();
  }

  void _openDetail(_Dist d) {
    context.push(
      '/distributors/${d.name}',
      extra: DistributorArg(
        name: d.name,
        city: d.city,
        brands: d.brands,
        initials: d.initials,
        fg: d.fg,
        bg: d.bg,
        linkStatus: _pendingConnect.contains(d.name) ? 'requested' : d.linkStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header — height animates when tab switches ────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20, 16, 20,
                  _tab == 0 ? 20 : 24, // more bottom pad on My tab for balance
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distributors',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    // Search bar — only visible on Discover tab
                    if (_tab == 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search by name, city or brand...',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white38),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Colors.white54, size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Custom tabs ────────────────────────────────────────────────
          Container(
            color: surfaceWhite,
            child: Row(
              children: ['Discover', 'My Distributors'].indexed.map((e) {
                final i = e.$1;
                final label = e.$2;
                final active = i == _tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _tab = i;
                      _search = '';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: active ? accentOrange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? accentOrange : textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(height: 1, color: borderColor),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: _tab == 0 ? _buildDiscover() : _buildMine(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildDiscover() {
    final list = _discoverFiltered;
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        message: 'No distributors found',
        subMessage: 'Try a different name, city or brand.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final d = list[i];
        final isPending =
            _pendingConnect.contains(d.name) || d.linkStatus == 'requested';
        return _DistCard(
          dist: d,
          onTap: () => _openDetail(d),
          trailing: isPending
              ? const StatusPill('requested')
              : d.linkStatus == 'approved'
                  ? const StatusPill('connected')
                  : _ConnectButton(
                      onTap: () =>
                          setState(() => _pendingConnect.add(d.name)),
                    ),
        );
      },
    );
  }

  Widget _buildMine() {
    if (_mine.isEmpty) {
      return const EmptyState(
        icon: Icons.store_outlined,
        message: 'No distributors yet',
        subMessage: 'Connect with distributors from the Discover tab.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _mine.length,
      itemBuilder: (_, i) {
        final d = _mine[i];
        return _DistCard(
          dist: d,
          onTap: () => _openDetail(d),
          trailing: d.linkStatus == 'approved'
              ? const StatusPill('connected')
              : const StatusPill('requested'),
        );
      },
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────
class _DistCard extends StatelessWidget {
  const _DistCard({
    required this.dist,
    required this.trailing,
    required this.onTap,
  });
  final _Dist dist;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            DistributorAvatar(
                initials: dist.initials, bg: dist.bg, fg: dist.fg, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dist.name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: textMuted),
                    const SizedBox(width: 2),
                    Text(dist.city,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: textSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Text(dist.brands,
                      style:
                          GoogleFonts.inter(fontSize: 11, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accentOrange,
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        child: Text('Connect',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}

class _Dist {
  const _Dist(this.name, this.city, this.brands, this.fg, this.bg,
      this.initials, this.linkStatus);
  final String name, city, brands, initials, linkStatus;
  final Color fg, bg;
}
