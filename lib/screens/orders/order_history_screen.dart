import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/distributor_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_pill.dart';

// ── Mock data ────────────────────────────────────────────────────────────────
const _mockOrders = [
  _Order('ORD-2401', 'Pak Paints',       'Rs. 12,400', 'approved',          '2 days ago',  4),
  _Order('ORD-2398', 'Royal Colors',     'Rs. 8,750',  'requested',         '4 days ago',  2),
  _Order('ORD-2391', 'Master Ply',       'Rs. 21,200', 'completed',         '1 week ago',  7),
  _Order('ORD-2385', 'Pak Paints',       'Rs. 5,600',  'out_for_delivery',  '1 week ago',  3),
  _Order('ORD-2379', 'National Dist.',   'Rs. 9,300',  'cancelled',         '2 weeks ago', 5),
  _Order('ORD-2371', 'Royal Colors',     'Rs. 15,800', 'completed',         '3 weeks ago', 6),
  _Order('ORD-2364', 'Master Ply',       'Rs. 3,200',  'rejected',          '1 month ago', 1),
  _Order('ORD-2358', 'National Dist.',   'Rs. 18,500', 'payment_confirmed', '1 month ago', 8),
];

const _tabs = ['All', 'Pending', 'Active', 'Completed', 'Cancelled'];

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  List<_Order> get _filtered {
    return switch (_tab) {
      1 => _mockOrders.where((o) => o.status == 'requested').toList(),
      2 => _mockOrders
          .where((o) => ['approved', 'payment_confirmed', 'out_for_delivery']
              .contains(o.status))
          .toList(),
      3 => _mockOrders
          .where((o) => ['completed', 'delivered'].contains(o.status))
          .toList(),
      4 => _mockOrders
          .where((o) => ['cancelled', 'rejected'].contains(o.status))
          .toList(),
      _ => _mockOrders,
    };
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;

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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'My Orders',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentOrange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(pillRadius),
                      ),
                      child: Text(
                        '${_mockOrders.length} orders',
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
            ),
          ),

          // ── Custom tab row ────────────────────────────────────────────
          Container(
            color: surfaceWhite,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final active = i == _tab;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: active ? accentOrange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active ? accentOrange : textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(height: 1, color: borderColor),

          // ── Order list ────────────────────────────────────────────────
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No orders here',
                    subMessage: 'Orders in this category will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: orders.length,
                    itemBuilder: (_, i) => _OrderCard(order: orders[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _Order order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}/tracking', extra: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  DistributorAvatar(
                    initials: order.distributor.substring(0, 2),
                    bg: infoBg,
                    fg: infoText,
                    size: 44,
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
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.distributor,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusPill(order.status),
                ],
              ),
            ),
            Container(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  _Meta(Icons.inventory_2_outlined,
                      '${order.itemCount} items'),
                  const SizedBox(width: 16),
                  _Meta(Icons.access_time_rounded, order.date),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(fontSize: 12, color: textSecondary)),
      ],
    );
  }
}

class _Order {
  const _Order(this.id, this.distributor, this.total, this.status, this.date,
      this.itemCount);
  final String id, distributor, total, status, date;
  final int itemCount;
}
