import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/status_pill.dart';
import '../distributors/distributor_detail_screen.dart';

// ── Searchable data ───────────────────────────────────────────────────────────

class _SearchItem {
  const _SearchItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    this.status,
    this.routeData,
  });
  final _ItemType type;
  final String title, subtitle, meta, initials;
  final Color avatarBg, avatarFg;
  final String? status;
  final Object? routeData;
}

enum _ItemType { order, distributor, product }

final _allItems = <_SearchItem>[
  // Orders
  _SearchItem(type: _ItemType.order, title: 'ORD-2401', subtitle: 'Pak Paints',
      meta: 'Rs. 12,400', initials: 'PA', avatarBg: infoBg, avatarFg: infoText,
      status: 'approved'),
  _SearchItem(type: _ItemType.order, title: 'ORD-2398', subtitle: 'Royal Colors',
      meta: 'Rs. 8,750', initials: 'RO', avatarBg: infoBg, avatarFg: infoText,
      status: 'requested'),
  _SearchItem(type: _ItemType.order, title: 'ORD-2391', subtitle: 'Master Ply',
      meta: 'Rs. 21,200', initials: 'MA', avatarBg: infoBg, avatarFg: infoText,
      status: 'completed'),
  _SearchItem(type: _ItemType.order, title: 'ORD-2385', subtitle: 'Pak Paints',
      meta: 'Rs. 5,600', initials: 'PA', avatarBg: infoBg, avatarFg: infoText,
      status: 'out_for_delivery'),
  _SearchItem(type: _ItemType.order, title: 'ORD-2379', subtitle: 'National Dist.',
      meta: 'Rs. 9,300', initials: 'NA', avatarBg: infoBg, avatarFg: infoText,
      status: 'cancelled'),

  // Distributors
  _SearchItem(type: _ItemType.distributor, title: 'Pak Paints', subtitle: 'Lahore',
      meta: 'Dulux · ICI · Jotun', initials: 'PP',
      avatarBg: Color(0xFFEEF2F8), avatarFg: Color(0xFF185FA5),
      status: 'approved',
      routeData: _DistRoute('Pak Paints', 'Lahore', 'Dulux · ICI · Jotun', 'PP',
          Color(0xFF185FA5), Color(0xFFEEF2F8), 'approved')),
  _SearchItem(type: _ItemType.distributor, title: 'Royal Colors', subtitle: 'Karachi',
      meta: 'Berger · Nippon', initials: 'RC',
      avatarBg: Color(0xFFF0EEFF), avatarFg: Color(0xFF6C5CE7),
      status: 'approved',
      routeData: _DistRoute('Royal Colors', 'Karachi', 'Berger · Nippon', 'RC',
          Color(0xFF6C5CE7), Color(0xFFF0EEFF), 'approved')),
  _SearchItem(type: _ItemType.distributor, title: 'Master Ply', subtitle: 'Faisalabad',
      meta: 'Century · Green Ply', initials: 'MP',
      avatarBg: Color(0xFFEAF8F2), avatarFg: Color(0xFF1A8A5A),
      status: 'approved',
      routeData: _DistRoute('Master Ply', 'Faisalabad', 'Century · Green Ply', 'MP',
          Color(0xFF1A8A5A), Color(0xFFEAF8F2), 'approved')),
  _SearchItem(type: _ItemType.distributor, title: 'National Dist.', subtitle: 'Multan',
      meta: 'ICI · Berger', initials: 'ND',
      avatarBg: Color(0xFFFFF8ED), avatarFg: Color(0xFFD97706),
      status: 'requested',
      routeData: _DistRoute('National Dist.', 'Multan', 'ICI · Berger', 'ND',
          Color(0xFFD97706), Color(0xFFFFF8ED), 'requested')),

  // Products
  _SearchItem(type: _ItemType.product, title: 'Dulux Exterior Paint',
      subtitle: 'Exterior', meta: 'Rs. 2,400 / 4L', initials: 'DU',
      avatarBg: Color(0xFFEEF2F8), avatarFg: Color(0xFF185FA5)),
  _SearchItem(type: _ItemType.product, title: 'Nippon Interior Emulsion',
      subtitle: 'Interior', meta: 'Rs. 1,600 / 4L', initials: 'NP',
      avatarBg: Color(0xFFFFF8ED), avatarFg: Color(0xFFD97706)),
  _SearchItem(type: _ItemType.product, title: 'Berger WeatherCoat',
      subtitle: 'Exterior', meta: 'Rs. 2,800 / 4L', initials: 'BG',
      avatarBg: Color(0xFFF0EEFF), avatarFg: Color(0xFF6C5CE7)),
  _SearchItem(type: _ItemType.product, title: 'Jotun Majestic',
      subtitle: 'Interior', meta: 'Rs. 3,200 / 4L', initials: 'JT',
      avatarBg: Color(0xFFEAF8F2), avatarFg: Color(0xFF1A8A5A)),
  _SearchItem(type: _ItemType.product, title: 'ICI Dulux Gloss',
      subtitle: 'Wood & Metal', meta: 'Rs. 1,100 / 1L', initials: 'IC',
      avatarBg: Color(0xFFFEF0EF), avatarFg: Color(0xFFD94A3A)),
  _SearchItem(type: _ItemType.product, title: 'Sika Waterproofing Coat',
      subtitle: 'Waterproofing', meta: 'Rs. 4,500 / 5kg', initials: 'SK',
      avatarBg: Color(0xFFEEF2F8), avatarFg: Color(0xFF185FA5)),
];

class _DistRoute {
  const _DistRoute(this.name, this.city, this.brands, this.initials,
      this.fg, this.bg, this.linkStatus);
  final String name, city, brands, initials, linkStatus;
  final Color fg, bg;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  static const _recentSearches = [
    'Dulux exterior', 'Pak Paints', 'ORD-2401', 'Berger'
  ];

  List<_SearchItem> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allItems.where((item) =>
        item.title.toLowerCase().contains(q) ||
        item.subtitle.toLowerCase().contains(q) ||
        item.meta.toLowerCase().contains(q)).toList();
  }

  void _onTap(_SearchItem item) {
    switch (item.type) {
      case _ItemType.order:
        context.push('/orders/${item.title}/tracking');
      case _ItemType.distributor:
        final d = item.routeData as _DistRoute;
        context.push(
          '/distributors/${Uri.encodeComponent(d.name)}',
          extra: DistributorArg(
            name: d.name, city: d.city, brands: d.brands,
            initials: d.initials, fg: d.fg, bg: d.bg,
            linkStatus: d.linkStatus,
          ),
        );
      case _ItemType.product:
        context.go('/distributors');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Search bar header ──────────────────────────────────────────
          Container(
            color: primaryNavy,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.inter(
                              fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search orders, distributors, products...',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: textMuted),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: textMuted, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        color: textMuted, size: 18),
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState()
                : results.isEmpty
                    ? _buildNoResults()
                    : _buildResults(results),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Text('Recent Searches',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.4)),
          const SizedBox(height: 12),
          ..._recentSearches.map((s) => ListTile(
                leading: const Icon(Icons.history_rounded,
                    color: textMuted, size: 20),
                title: Text(s,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: textPrimary)),
                trailing: const Icon(Icons.north_west_rounded,
                    color: textMuted, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  _controller.text = s;
                  setState(() => _query = s);
                },
              )),

          const SizedBox(height: 24),

          // Browse categories
          Text('Browse',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.4)),
          const SizedBox(height: 12),
          _BrowseChip(
            icon: Icons.receipt_long_rounded,
            label: 'My Orders',
            color: infoText,
            bg: infoBg,
            onTap: () => context.go('/orders'),
          ),
          const SizedBox(height: 8),
          _BrowseChip(
            icon: Icons.store_rounded,
            label: 'Distributors',
            color: purpleText,
            bg: purpleBg,
            onTap: () => context.go('/distributors'),
          ),
          const SizedBox(height: 8),
          _BrowseChip(
            icon: Icons.format_paint_rounded,
            label: 'Browse Stock',
            color: successText,
            bg: successBg,
            onTap: () => context.go('/distributors'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: textMuted),
          const SizedBox(height: 12),
          Text('No results for "$_query"',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
          const SizedBox(height: 4),
          Text('Try a different keyword',
              style: GoogleFonts.inter(
                  fontSize: 13, color: textSecondary)),
        ],
      ),
    );
  }

  Widget _buildResults(List<_SearchItem> results) {
    // Group by type
    final orders = results.where((r) => r.type == _ItemType.order).toList();
    final dists  = results.where((r) => r.type == _ItemType.distributor).toList();
    final prods  = results.where((r) => r.type == _ItemType.product).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (orders.isNotEmpty) ...[
          _GroupLabel('Orders', orders.length),
          ...orders.map((r) => _ResultTile(item: r, query: _query, onTap: () => _onTap(r))),
          const SizedBox(height: 8),
        ],
        if (dists.isNotEmpty) ...[
          _GroupLabel('Distributors', dists.length),
          ...dists.map((r) => _ResultTile(item: r, query: _query, onTap: () => _onTap(r))),
          const SizedBox(height: 8),
        ],
        if (prods.isNotEmpty) ...[
          _GroupLabel('Products', prods.length),
          ...prods.map((r) => _ResultTile(item: r, query: _query, onTap: () => _onTap(r))),
        ],
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label, this.count);
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.4)),
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile(
      {required this.item, required this.query, required this.onTap});
  final _SearchItem item;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            DistributorAvatar(
              initials: item.initials,
              bg: item.avatarBg,
              fg: item.avatarFg,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightText(item.title, query),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (item.status != null) StatusPill(item.status!) else
              Text(item.meta,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryNavy)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: textMuted),
          ],
        ),
      ),
    );
  }
}

// Highlights the matched portion in bold orange
class _HighlightText extends StatelessWidget {
  const _HighlightText(this.text, this.query);
  final String text, query;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary));
    }
    final lower = text.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());
    if (idx < 0) {
      return Text(text,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary));
    }
    return Text.rich(TextSpan(children: [
      if (idx > 0)
        TextSpan(
            text: text.substring(0, idx),
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary)),
      TextSpan(
          text: text.substring(idx, idx + query.length),
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accentOrange)),
      if (idx + query.length < text.length)
        TextSpan(
            text: text.substring(idx + query.length),
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary)),
    ]));
  }
}

class _BrowseChip extends StatelessWidget {
  const _BrowseChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: textMuted),
          ],
        ),
      ),
    );
  }
}
