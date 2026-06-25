import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/status_pill.dart';
import '../stock/stock_browse_screen.dart';

class DistributorDetailScreen extends StatefulWidget {
  const DistributorDetailScreen({super.key, required this.dist});
  final DistributorArg dist;

  @override
  State<DistributorDetailScreen> createState() =>
      _DistributorDetailScreenState();
}

class _DistributorDetailScreenState extends State<DistributorDetailScreen> {
  late String _linkStatus;


  @override
  void initState() {
    super.initState();
    _linkStatus = widget.dist.linkStatus;
  }

  DistributorArg get dist => widget.dist;

  void _callDistributor() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CallSheet(
        distributorName: dist.name,
        phone: dist.phone.isNotEmpty ? dist.phone : 'Not available',
      ),
    );
  }

  void _sendConnectRequest() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConnectSheet(
        distributorName: dist.name,
        city: dist.city,
        initials: dist.initials,
        fg: dist.fg,
        bg: dist.bg,
        onConfirm: () {
          Navigator.pop(context);
          setState(() => _linkStatus = 'requested');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connection request sent to ${dist.name}!',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ]),
            backgroundColor: successText,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius)),
            duration: const Duration(seconds: 3),
          ));
        },
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
          Container(
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
                child: Column(
                  children: [
                    // Back row
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        if (_linkStatus != 'none') StatusPill(_linkStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Avatar + name block
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        DistributorAvatar(
                          initials: dist.initials,
                          bg: dist.bg,
                          fg: dist.fg,
                          size: 60,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dist.name,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 13, color: Colors.white54),
                                  const SizedBox(width: 3),
                                  Text(
                                    dist.city,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.white60),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dist.brands,
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white38),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact info card
                  _InfoCard(
                    title: 'Contact Info',
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: dist.phone.isNotEmpty
                              ? dist.phone
                              : 'Not available',
                        ),
                        if (dist.city.isNotEmpty) ...[
                          const Divider(height: 1, indent: 44, color: borderColor),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'City',
                            value: dist.city,
                          ),
                        ],
                        if (dist.address.isNotEmpty) ...[
                          const Divider(height: 1, indent: 44, color: borderColor),
                          _InfoRow(
                            icon: Icons.store_outlined,
                            label: 'Address',
                            value: dist.address,
                            last: true,
                          ),
                        ],
                        if (dist.email.isNotEmpty) ...[
                          const Divider(height: 1, indent: 44, color: borderColor),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: dist.email,
                            last: true,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Brands card
                  _InfoCard(
                    title: 'Brands Available',
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dist.brands
                            .split(' · ')
                            .map((b) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius:
                                        BorderRadius.circular(pillRadius),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    b.trim(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Products preview — tappable rows
                  _InfoCard(
                    title: 'Products  (tap to view details)',
                    child: Column(
                      children: List.generate(catalogue.length, (i) {
                        final p = catalogue[i];
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => context.push(
                                '/product/${p.id}',
                                extra: ProductDetailArg(
                                  product: p,
                                  distributorName: dist.name,
                                ),
                              ),
                              borderRadius: i == catalogue.length - 1
                                  ? const BorderRadius.vertical(
                                      bottom: Radius.circular(cardRadius))
                                  : BorderRadius.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    DistributorAvatar(
                                      initials: p.initials,
                                      bg: p.avatarBg,
                                      fg: p.avatarFg,
                                      size: 36,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: textPrimary,
                                            ),
                                          ),
                                          Text(
                                            p.colors.take(3).join(' · '),
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rs. ${p.pricePerUnit.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: primaryNavy,
                                          ),
                                        ),
                                        Text(
                                          '/ ${p.unit}',
                                          style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: textMuted),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded,
                                        size: 16, color: textMuted),
                                  ],
                                ),
                              ),
                            ),
                            if (i < catalogue.length - 1)
                              const Divider(
                                  height: 1,
                                  indent: 64,
                                  color: borderColor),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Action buttons (reactive to _linkStatus) ─────────
                  if (_linkStatus == 'approved') ...[
                    ElevatedButton.icon(
                      onPressed: () => context.push(
                        '/stock/${Uri.encodeComponent(dist.name)}',
                        extra: dist.name,
                      ),
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: const Text('Browse Stock'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _callDistributor,
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Call Distributor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryNavy,
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                    ),
                  ] else if (_linkStatus == 'requested') ...[
                    // Pending banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: warningBg,
                        borderRadius: BorderRadius.circular(buttonRadius),
                        border: Border.all(
                            color: warningText.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              color: warningText, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Connection request pending approval',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: warningText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _callDistributor,
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Call Distributor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryNavy,
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Not connected yet — send request
                    ElevatedButton.icon(
                      onPressed: _sendConnectRequest,
                      icon: const Icon(Icons.link_rounded, size: 18),
                      label: const Text('Send Connect Request'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _callDistributor,
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Call Distributor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryNavy,
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info card shell ───────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: borderColor),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });
  final IconData icon;
  final String label, value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.inter(fontSize: 13, color: textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textPrimary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Call bottom sheet ─────────────────────────────────────────────────────────
class _CallSheet extends StatelessWidget {
  const _CallSheet(
      {required this.distributorName, required this.phone});
  final String distributorName, phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.phone_rounded,
                color: infoText, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            'Call $distributorName',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            phone,
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: primaryNavy,
                letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          Text(
            'Mon–Sat  9:00 AM – 6:00 PM',
            style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textSecondary,
                    side: const BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling $phone…',
                            style: GoogleFonts.inter(fontSize: 13)),
                        backgroundColor: primaryNavy,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(buttonRadius)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Connect request bottom sheet ──────────────────────────────────────────────
class _ConnectSheet extends StatelessWidget {
  const _ConnectSheet({
    required this.distributorName,
    required this.city,
    required this.initials,
    required this.fg,
    required this.bg,
    required this.onConfirm,
  });
  final String distributorName, city, initials;
  final Color fg, bg;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2)),
          ),

          // Distributor avatar
          DistributorAvatar(initials: initials, bg: bg, fg: fg, size: 60),
          const SizedBox(height: 14),

          Text(
            'Connect with $distributorName?',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.location_on_outlined,
                size: 13, color: textMuted),
            const SizedBox(width: 3),
            Text(city,
                style:
                    GoogleFonts.inter(fontSize: 13, color: textSecondary)),
          ]),

          const SizedBox(height: 20),

          // What happens note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: infoText.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What happens next?',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: infoText)),
                const SizedBox(height: 6),
                ...[
                  'Your request is sent to the distributor',
                  'They will review and approve your account',
                  'Once approved, you can browse stock and place orders',
                ].map((s) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 13, color: infoText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(s,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: infoText,
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textSecondary,
                    side: const BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Send Request'),
                  style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Argument passed via go_router extra ──────────────────────────────────────
class DistributorArg {
  const DistributorArg({
    required this.name,
    required this.city,
    required this.brands,
    required this.initials,
    required this.fg,
    required this.bg,
    required this.linkStatus,
    this.phone   = '',
    this.address = '',
    this.email   = '',
  });
  final String name, city, brands, initials, linkStatus;
  final String phone, address, email;
  final Color fg, bg;
}
