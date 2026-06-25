import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../widgets/status_pill.dart';
import 'payment_details_screen.dart';

// ── Status progression ────────────────────────────────────────────────────────
// requested → approved → payment_submitted → payment_confirmed → out_for_delivery → completed

const _statusOrder = [
  'requested',
  'approved',
  'payment_submitted',
  'payment_confirmed',
  'out_for_delivery',
  'completed',
];

int _statusIndex(String s) => _statusOrder.indexOf(s);

// ── Timeline step definitions ─────────────────────────────────────────────────
class _StepDef {
  const _StepDef(this.label, this.sub, this.icon);
  final String label, sub;
  final IconData icon;
}

const _stepDefs = [
  _StepDef('Order Placed',
      'Your order has been sent to the wholesaler',
      Icons.receipt_long_rounded),
  _StepDef('Order Approved',
      'Wholesaler confirmed your order via call/message',
      Icons.check_circle_rounded),
  _StepDef('Payment Submitted',
      'Payment proof shared with wholesaler via WhatsApp',
      Icons.payments_rounded),
  _StepDef('Payment Confirmed',
      'Wholesaler received and verified your payment',
      Icons.verified_rounded),
  _StepDef('Out for Delivery',
      'Stock is being dispatched to your shop',
      Icons.local_shipping_rounded),
  _StepDef('Delivered',
      'Order successfully delivered to your shop',
      Icons.storefront_rounded),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Start at 'approved' so user sees the payment prompt in the demo
  String _status = 'approved';

  static const _distributorName  = 'Pak Paints';
  static const _distributorPhone = '+92 300 9876543';
  static const _total            = 'Rs. 12,400';
  static const _totalAmount      = 12400;
  static const _itemCount        = 3;

  bool get _isCancelled => _status == 'cancelled';

  // ── Actions ────────────────────────────────────────────────────────────────

  void _openPayment() async {
    final paid = await context.push<bool>(
      '/payment/${widget.orderId}',
      extra: PaymentArg(
        orderId: widget.orderId,
        distributorName: _distributorName,
        distributorPhone: _distributorPhone,
        total: _total,
        totalAmount: _totalAmount,
        itemCount: _itemCount,
      ),
    );
    if (paid == true && mounted) {
      setState(() => _status = 'payment_submitted');
    }
  }

  void _callDistributor() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CallSheet(
          distributorName: _distributorName, phone: _distributorPhone),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Text('Cancel Order',
            style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textPrimary)),
        content: Text(
            'Are you sure you want to cancel ${widget.orderId}? This action cannot be undone.',
            style: GoogleFonts.inter(
                fontSize: 14, color: textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Order',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _status = 'cancelled');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text('${widget.orderId} has been cancelled.',
                      style: GoogleFonts.inter(fontSize: 13)),
                ]),
                backgroundColor: dangerText,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                duration: const Duration(seconds: 3),
              ));
            },
            child: Text('Cancel Order',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: dangerText)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentIdx = _isCancelled ? -1 : _statusIndex(_status);

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
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          widget.orderId,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        StatusPill(_status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(children: [
                        Text('$_distributorName  ·  ',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white60)),
                        Text(_total,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status banners ─────────────────────────────────
                  if (_status == 'approved') ...[
                    _PaymentBanner(onTap: _openPayment),
                    const SizedBox(height: 16),
                  ],
                  if (_status == 'payment_submitted') ...[
                    _InfoBanner(
                      icon: Icons.schedule_rounded,
                      color: warningText,
                      bg: warningBg,
                      message:
                          'Payment proof shared. Waiting for $_distributorName to confirm receipt.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_status == 'payment_confirmed') ...[
                    _InfoBanner(
                      icon: Icons.verified_rounded,
                      color: successText,
                      bg: successBg,
                      message:
                          'Payment confirmed! Your order is being prepared for dispatch.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_status == 'out_for_delivery') ...[
                    _InfoBanner(
                      icon: Icons.local_shipping_rounded,
                      color: infoText,
                      bg: infoBg,
                      message:
                          'Your order is on the way! Expected delivery today.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_status == 'completed') ...[
                    _InfoBanner(
                      icon: Icons.check_circle_rounded,
                      color: successText,
                      bg: successBg,
                      message:
                          'Delivered! Order completed successfully. Thank you.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_isCancelled) ...[
                    _InfoBanner(
                      icon: Icons.cancel_rounded,
                      color: dangerText,
                      bg: dangerBg,
                      message: 'This order has been cancelled.',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Timeline ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Timeline',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                              letterSpacing: 0.3,
                            )),
                        const SizedBox(height: 16),
                        ...List.generate(_stepDefs.length, (i) {
                          late _TileState state;
                          if (_isCancelled) {
                            state = _TileState.upcoming;
                          } else if (i < currentIdx) {
                            state = _TileState.done;
                          } else if (i == currentIdx) {
                            state = _TileState.current;
                          } else {
                            state = _TileState.upcoming;
                          }
                          return _TimelineRow(
                            def: _stepDefs[i],
                            state: state,
                            isLast: i == _stepDefs.length - 1,
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Order items ────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 14, 16, 10),
                          child: Text('Order Items',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                  letterSpacing: 0.3)),
                        ),
                        const Divider(height: 1, color: borderColor),
                        ...[
                          ('Dulux Exterior Paint', 'White · 4L',  2, 'Rs. 4,800'),
                          ('Nippon Interior',      'Cream · 1L',  2, 'Rs. 3,200'),
                          ('Berger Weather Coat',  'Grey · 16L',  1, 'Rs. 4,400'),
                        ].map((item) => _ItemRow(
                              name: item.$1,
                              detail: item.$2,
                              qty: item.$3,
                              price: item.$4)),
                        const Divider(height: 1, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary)),
                              Text(_total,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: primaryNavy,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Action buttons ─────────────────────────────────
                  // "Make Payment" primary CTA when approved
                  if (_status == 'approved') ...[
                    ElevatedButton.icon(
                      onPressed: _openPayment,
                      icon: const Icon(Icons.payments_rounded, size: 18),
                      label: const Text('Make Payment'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _callDistributor,
                          icon: const Icon(Icons.phone_outlined, size: 18),
                          label: const Text('Call Wholesaler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryNavy,
                            side: const BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    buttonRadius)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isCancelled ||
                                  _statusIndex(_status) >= 3
                              ? null
                              : _confirmCancel,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(_isCancelled
                              ? 'Cancelled'
                              : _statusIndex(_status) >= 3
                                  ? 'In Progress'
                                  : 'Cancel Order'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: dangerText,
                            disabledForegroundColor: textMuted,
                            side: BorderSide(
                                color: (_isCancelled ||
                                        _statusIndex(_status) >= 3)
                                    ? borderColor
                                    : dangerText
                                        .withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    buttonRadius)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment required banner ───────────────────────────────────────────────────
class _PaymentBanner extends StatelessWidget {
  const _PaymentBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: accentOrange.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.payments_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Required',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C4700))),
                  Text(
                      'Order approved! Tap to view payment details and pay.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Color(0xFF9E6000))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: accentOrange, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Generic info banner ───────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.bg,
    required this.message,
  });
  final IconData icon;
  final Color color, bg;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ),
      ]),
    );
  }
}

// ── Timeline row ──────────────────────────────────────────────────────────────
enum _TileState { done, current, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow(
      {required this.def, required this.state, required this.isLast});
  final _StepDef def;
  final _TileState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone    = state == _TileState.done;
    final isCurrent = state == _TileState.current;

    final circleColor = isDone
        ? successText
        : isCurrent
            ? accentOrange
            : borderColor;
    final iconColor =
        isDone || isCurrent ? Colors.white : textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: (!isDone && !isCurrent)
                      ? Border.all(color: borderColor, width: 1.5)
                      : null,
                ),
                child: Icon(def.icon, size: 15, color: iconColor),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 38,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isDone
                      ? successText.withValues(alpha: 0.3)
                      : borderColor,
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                top: 6, bottom: isLast ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(def.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isCurrent || isDone
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isCurrent || isDone
                          ? textPrimary
                          : textMuted,
                    )),
                const SizedBox(height: 2),
                Text(def.sub,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isCurrent || isDone
                            ? textSecondary
                            : textMuted)),
              ],
            ),
          ),
        ),
      ],
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
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                color: infoBg,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.phone_rounded,
                color: infoText, size: 26),
          ),
          const SizedBox(height: 14),
          Text('Call $distributorName',
              style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          const SizedBox(height: 6),
          Text(phone,
              style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: primaryNavy,
                  letterSpacing: 1)),
          const SizedBox(height: 6),
          Text('Mon–Sat  9:00 AM – 6:00 PM',
              style: GoogleFonts.inter(
                  fontSize: 12, color: textSecondary)),
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
                        borderRadius:
                            BorderRadius.circular(buttonRadius)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Calling $phone…',
                          style: GoogleFonts.inter(fontSize: 13)),
                      backgroundColor: primaryNavy,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(buttonRadius)),
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const Text('Call Now'),
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

// ── Item row ──────────────────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  const _ItemRow(
      {required this.name,
      required this.detail,
      required this.qty,
      required this.price});
  final String name, detail, price;
  final int qty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textPrimary)),
                Text('$detail  ×$qty',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
          Text(price,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
        ],
      ),
    );
  }
}
