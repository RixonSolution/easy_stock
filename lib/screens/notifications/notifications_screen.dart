import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';

// ── Mock notifications ────────────────────────────────────────────────────────

class _Notif {
  const _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
    this.route,
  });
  final String id, title, body, time;
  final _NotifType type;
  final bool read;
  final String? route;
}

enum _NotifType { order, distributor, payment, system }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifs = [
    const _Notif(
      id: 'n1', type: _NotifType.order,
      title: 'Order Approved',
      body: 'ORD-2401 from Pak Paints has been approved and is being processed.',
      time: '2 min ago',
      route: '/orders/ORD-2401/tracking',
    ),
    const _Notif(
      id: 'n2', type: _NotifType.payment,
      title: 'Payment Confirmed',
      body: 'Payment of Rs. 12,400 for ORD-2401 has been received by wholesaler.',
      time: '1 hour ago',
      route: '/orders/ORD-2401/tracking',
    ),
    const _Notif(
      id: 'n3', type: _NotifType.distributor,
      title: 'New Connection',
      body: 'ColorMax Wholesalers accepted your connection request.',
      time: '3 hours ago',
      route: '/distributors',
      read: true,
    ),
    const _Notif(
      id: 'n4', type: _NotifType.order,
      title: 'Out for Delivery',
      body: 'ORD-2385 is out for delivery. Expected arrival today between 2–5 PM.',
      time: 'Yesterday',
      route: '/orders/ORD-2385/tracking',
      read: true,
    ),
    const _Notif(
      id: 'n5', type: _NotifType.system,
      title: 'Subscription Renewing',
      body: 'Your Pro Plan renews in 7 days (15 Jul 2026). Rs. 2,500 will be charged.',
      time: '2 days ago',
      read: true,
    ),
    const _Notif(
      id: 'n6', type: _NotifType.order,
      title: 'Order Completed',
      body: 'ORD-2391 from Master Ply has been delivered and marked complete.',
      time: '1 week ago',
      route: '/orders',
      read: true,
    ),
    const _Notif(
      id: 'n7', type: _NotifType.distributor,
      title: 'Stock Update',
      body: 'Royal Colors has updated their product catalogue with new items.',
      time: '1 week ago',
      route: '/distributors',
      read: true,
    ),
  ];

  final Set<String> _readIds = {};

  bool _isRead(_Notif n) => n.read || _readIds.contains(n.id);

  int get _unreadCount => _notifs.where((n) => !_isRead(n)).length;

  void _markAllRead() => setState(() => _readIds.addAll(_notifs.map((n) => n.id)));

  void _onTap(_Notif n) {
    setState(() => _readIds.add(n.id));
    if (n.route != null) context.push(n.route!);
  }

  IconData _icon(_NotifType t) => switch (t) {
        _NotifType.order       => Icons.receipt_long_rounded,
        _NotifType.distributor => Icons.store_rounded,
        _NotifType.payment     => Icons.payments_rounded,
        _NotifType.system      => Icons.info_outline_rounded,
      };

  Color _iconColor(_NotifType t) => switch (t) {
        _NotifType.order       => infoText,
        _NotifType.distributor => purpleText,
        _NotifType.payment     => successText,
        _NotifType.system      => warningText,
      };

  Color _iconBg(_NotifType t) => switch (t) {
        _NotifType.order       => infoBg,
        _NotifType.distributor => purpleBg,
        _NotifType.payment     => successBg,
        _NotifType.system      => warningBg,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Navy header ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: primaryNavy,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_unreadCount > 0)
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Text(
                          'Mark all read',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: accentOrange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Unread badge row ─────────────────────────────────────────
          if (_unreadCount > 0)
            Container(
              color: surfaceWhite,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_unreadCount unread',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(height: 1, color: borderColor),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: _notifs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_off_outlined,
                            size: 48, color: textMuted),
                        const SizedBox(height: 12),
                        Text('No notifications yet',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textPrimary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                    itemCount: _notifs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: borderColor),
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      final read = _isRead(n);
                      return GestureDetector(
                        onTap: () => _onTap(n),
                        child: Container(
                          color: read
                              ? surfaceWhite
                              : accentOrange.withValues(alpha: 0.04),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon circle
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _iconBg(n.type),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_icon(n.type),
                                    color: _iconColor(n.type), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: read
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(n.time,
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: textMuted)),
                                    ]),
                                    const SizedBox(height: 3),
                                    Text(
                                      n.body,
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: read
                                              ? textSecondary
                                              : textPrimary,
                                          height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Unread dot
                              if (!read)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                    color: accentOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
