import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connections_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_pill.dart';
import 'distributor_detail_screen.dart';

// ── Color palette cycled per wholesaler index ────────────────────────────────
const _fgColors = [
  Color(0xFF185FA5),
  Color(0xFF6C5CE7),
  Color(0xFF1A8A5A),
  Color(0xFFD97706),
  Color(0xFFD94A3A),
];
const _bgColors = [
  Color(0xFFEEF2F8),
  Color(0xFFF0EEFF),
  Color(0xFFEAF8F2),
  Color(0xFFFFF8ED),
  Color(0xFFFEF0EF),
];

// ── Wholesaler model ─────────────────────────────────────────────────────────
class _Wholesaler {
  _Wholesaler({
    required this.id,
    required this.name,
    required this.city,
    required this.brands,
    required this.initials,
    required this.fg,
    required this.bg,
    this.phone   = '',
    this.address = '',
    this.email   = '',
  });

  final String id;
  final String name;
  final String city;
  final String brands;
  final String initials;
  final String phone;
  final String address;
  final String email;
  final Color fg;
  final Color bg;

  factory _Wholesaler.fromDoc(QueryDocumentSnapshot doc, int index) {
    final d = doc.data() as Map<String, dynamic>;

    // businessName = shop/business display name; ownerName = person name
    final businessName = (d['businessName'] as String?)?.trim() ?? '';
    final ownerName    = (d['ownerName']    as String?)?.trim() ?? '';
    final name         = businessName.isNotEmpty ? businessName : ownerName;

    // city = primary city where wholesaler is based
    final city    = (d['city']    as String?)?.trim() ?? '';
    final phone   = (d['phone']   as String?)?.trim() ?? '';
    final address = (d['address'] as String?)?.trim() ?? '';
    final email   = (d['email']   as String?)?.trim() ?? '';

    // brands stored as List in Firestore
    String brands = '';
    final rawBrands = d['brands'];
    if (rawBrands is List && rawBrands.isNotEmpty) {
      brands = rawBrands.map((e) => e.toString().trim()).join(' · ');
    } else if (rawBrands is String && rawBrands.isNotEmpty) {
      brands = rawBrands.trim();
    }

    // 2-letter initials from business/owner name
    final parts    = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty
            ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
            : 'WS');

    final i = index % _fgColors.length;

    return _Wholesaler(
      id:       doc.id,
      name:     name.isNotEmpty ? name : 'Wholesaler',
      city:     city,
      brands:   brands,
      initials: initials,
      phone:    phone,
      address:  address,
      email:    email,
      fg:       _fgColors[i],
      bg:       _bgColors[i],
    );
  }
}


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

  // Firestore query — approved + active subscription + not suspended
  Stream<QuerySnapshot> get _wholesalersStream => FirebaseFirestore.instance
      .collection('wholesalers')
      .where('verificationStatus', isEqualTo: 'approved')
      .where('subscriptionStatus', isEqualTo: 'active')
      .where('suspended', isEqualTo: false)
      .snapshots();

  void _openDetail(_Wholesaler w, String linkStatus) {
    context.push(
      '/distributors/${Uri.encodeComponent(w.name)}',
      extra: DistributorArg(
        name:       w.name,
        city:       w.city,
        brands:     w.brands,
        initials:   w.initials,
        fg:         w.fg,
        bg:         w.bg,
        linkStatus: linkStatus,
        phone:      w.phone,
        address:    w.address,
        email:      w.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header ────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, _tab == 0 ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wholesalers',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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

          // ── Tabs ──────────────────────────────────────────────────────
          Container(
            color: surfaceWhite,
            child: Row(
              children: ['Discover', 'My Wholesalers'].indexed.map((e) {
                final i     = e.$1;
                final label = e.$2;
                final active = i == _tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _tab   = i;
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

          // ── List body ─────────────────────────────────────────────────
          Expanded(
            child: _tab == 0 ? _buildDiscover() : _buildMine(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  // ── Discover — live from Firestore ───────────────────────────────────────
  Widget _buildDiscover() {
    return StreamBuilder<QuerySnapshot>(
      stream: _wholesalersStream,
      builder: (context, snapshot) {
        // Loading — shimmer skeleton cards
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerList();
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: textMuted),
                const SizedBox(height: 12),
                Text(
                  'Failed to load wholesalers',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your connection and try again.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          );
        }

        // Build list of models
        final docs = snapshot.data?.docs ?? [];
        final all  = docs.asMap().entries.map((e) =>
            _Wholesaler.fromDoc(e.value, e.key)).toList();

        // Apply search filter
        final list = _search.isEmpty
            ? all
            : all.where((w) {
                final q = _search.toLowerCase();
                return w.name.toLowerCase().contains(q) ||
                    w.city.toLowerCase().contains(q) ||
                    w.brands.toLowerCase().contains(q);
              }).toList();

        if (list.isEmpty && _search.isNotEmpty) {
          return const EmptyState(
            icon: Icons.search_off_rounded,
            message: 'No wholesalers found',
            subMessage: 'Try a different name, city or brand.',
          );
        }

        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.store_outlined,
            message: 'No wholesalers available',
            subMessage: 'Check back soon — new wholesalers are added regularly.',
          );
        }

        final connections = context.watch<ConnectionsProvider>();
        final auth        = context.read<AuthProvider>();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final w      = list[i];
            final status = connections.statusFor(w.id);

            // Approved wholesalers move to My Wholesalers tab
            if (status == 'approved') return const SizedBox.shrink();

            Widget trailing;
            if (status == 'pending') {
              trailing = const StatusPill('requested');
            } else if (status == 'blocked') {
              trailing = const StatusPill('blocked');
            } else {
              // 'none' or 'rejected' — show Connect button
              trailing = _ConnectButton(
                onTap: () async {
                  try {
                    await connections.sendRequest(
                      retailerId:           auth.uid,
                      retailerName:         auth.shopName,
                      retailerCity:         auth.city,
                      wholesalerId:         w.id,
                      wholesalerName:       w.name,
                      wholesalerCity:       w.city,
                      wholesalerBrands:     w.brands,
                      wholesalerPhone:      w.phone,
                      wholesalerAddress:    w.address,
                      wholesalerEmail:      w.email,
                      wholesalerColorIndex: i % _fgColors.length,
                    );
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to send request. Please try again.',
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                          backgroundColor: dangerText,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(buttonRadius),
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            }

            return _DistCard(

              name:     w.name,
              city:     w.city,
              brands:   w.brands,
              initials: w.initials,
              fg:       w.fg,
              bg:       w.bg,
              onTap:    () => _openDetail(w, status),
              trailing: trailing,
            );
          },
        );
      },
    );
  }

  // ── My Wholesalers — live from connections collection ────────────────────
  Widget _buildMine() {
    final uid = context.read<AuthProvider>().uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('connections')
          .where('retailerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerList();
        }

        if (snapshot.hasError) {
          debugPrint('My Wholesalers stream error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: textMuted),
                const SizedBox(height: 12),
                Text(
                  'Failed to load connections.',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check your connection and try again.',
                  style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // My Wholesalers: approved only. Everything else stays in Discover.
        final visible = docs.where((d) {
          final status = (d.data() as Map<String, dynamic>)['status'] as String? ?? '';
          return status == 'approved';
        }).toList();

        if (visible.isEmpty) {
          return const EmptyState(
            icon: Icons.store_outlined,
            message: 'No wholesalers yet',
            subMessage: 'Connect with wholesalers from the Discover tab.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: visible.length,
          itemBuilder: (_, i) {
            final data          = visible[i].data() as Map<String, dynamic>;
            final status        = data['status']              as String? ?? 'pending';
            // wholesalerId kept for future use (e.g. cancel/block actions)
            // ignore: unused_local_variable
            final wholesalerId  = data['wholesalerId']        as String? ?? '';
            final name          = data['wholesalerName']      as String? ?? 'Wholesaler';
            final city          = data['wholesalerCity']      as String? ?? '';
            final brands        = data['wholesalerBrands']    as String? ?? '';
            final phone         = data['wholesalerPhone']     as String? ?? '';
            final address       = data['wholesalerAddress']   as String? ?? '';
            final email         = data['wholesalerEmail']     as String? ?? '';
            final colorIndex    = (data['wholesalerColorIndex'] as int?) ?? i;
            final ci            = colorIndex % _fgColors.length;

            // Generate initials from name
            final parts    = name.trim().split(RegExp(r'\s+'));
            final initials = parts.length >= 2
                ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                : (name.isNotEmpty
                    ? name.substring(0, name.length.clamp(0, 2)).toUpperCase()
                    : 'WS');

            Widget trailing;
            if (status == 'approved') {
              trailing = const StatusPill('connected');
            } else if (status == 'blocked') {
              trailing = const StatusPill('blocked');
            } else {
              trailing = const StatusPill('requested');
            }

            return _DistCard(
              name:     name,
              city:     city,
              brands:   brands,
              initials: initials,
              fg:       _fgColors[ci],
              bg:       _bgColors[ci],
              onTap: () => context.push(
                '/distributors/${Uri.encodeComponent(name)}',
                extra: DistributorArg(
                  name:       name,
                  city:       city,
                  brands:     brands,
                  initials:   initials,
                  fg:         _fgColors[ci],
                  bg:         _bgColors[ci],
                  linkStatus: status,
                  phone:      phone,
                  address:    address,
                  email:      email,
                ),
              ),
              trailing: trailing,
            );
          },
        );
      },
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────
class _DistCard extends StatelessWidget {
  const _DistCard({
    required this.name,
    required this.city,
    required this.brands,
    required this.initials,
    required this.fg,
    required this.bg,
    required this.trailing,
    required this.onTap,
  });
  final String name, city, brands, initials;
  final Color fg, bg;
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
            DistributorAvatar(initials: initials, bg: bg, fg: fg, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary)),
                  const SizedBox(height: 2),
                  if (city.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: textMuted),
                      const SizedBox(width: 2),
                      Text(city,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary)),
                    ]),
                  if (brands.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(brands,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
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

// ── Shimmer skeleton list ─────────────────────────────────────────────────────
class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EDF3),
      highlightColor: const Color(0xFFF4F6FA),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              // Text lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Connect button placeholder
              Container(
                width: 72,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

