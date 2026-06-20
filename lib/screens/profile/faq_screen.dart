import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<int> _expanded = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const _faqs = [
    _FaqItem(
      category: 'Orders',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF185FA5),
      q: 'How do I place a new order?',
      a: 'Go to a distributor\'s detail page and tap "Browse Stock". Select the products and quantities you need, then tap "Add to Order". Review your order and confirm. The distributor will receive your request and approve or modify it.',
    ),
    _FaqItem(
      category: 'Orders',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF185FA5),
      q: 'How do I track my order status?',
      a: 'Open the Orders tab and tap on any order card. The Order Tracking screen shows a live timeline: Order Placed → Approved → Payment Submitted → Payment Confirmed → Out for Delivery → Delivered.',
    ),
    _FaqItem(
      category: 'Orders',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF185FA5),
      q: 'Can I cancel an order after placing it?',
      a: 'Yes, you can cancel an order as long as it hasn\'t been confirmed for delivery (status is before "Payment Confirmed"). Open the order, scroll down, and tap "Cancel Order".',
    ),
    _FaqItem(
      category: 'Payments',
      icon: Icons.payments_rounded,
      color: Color(0xFF1A8A5A),
      q: 'Which payment methods are supported?',
      a: 'EasyStock supports EasyPaisa, JazzCash, and direct bank transfer. After a distributor approves your order, go to the payment screen to see their account details. Make the transfer and share your screenshot via WhatsApp.',
    ),
    _FaqItem(
      category: 'Payments',
      icon: Icons.payments_rounded,
      color: Color(0xFF1A8A5A),
      q: 'How does the distributor confirm my payment?',
      a: 'After you share your payment screenshot on WhatsApp, the distributor reviews it and confirms receipt. Once confirmed, your order status automatically updates to "Payment Confirmed" and then moves to "Out for Delivery".',
    ),
    _FaqItem(
      category: 'Payments',
      icon: Icons.payments_rounded,
      color: Color(0xFF1A8A5A),
      q: 'What if my payment is not confirmed?',
      a: 'If the distributor hasn\'t confirmed after 24 hours, use the "Call Distributor" button on the order tracking screen to follow up. You can also reach out via WhatsApp to the same number you sent the screenshot to.',
    ),
    _FaqItem(
      category: 'Distributors',
      icon: Icons.store_rounded,
      color: Color(0xFF6C5CE7),
      q: 'How do I connect with a new distributor?',
      a: 'Go to the Distributors tab and select "Discover". Browse the list and tap on a distributor to view their details. Tap "Send Connect Request" to send a connection request. Once approved, you can browse their stock and place orders.',
    ),
    _FaqItem(
      category: 'Distributors',
      icon: Icons.store_rounded,
      color: Color(0xFF6C5CE7),
      q: 'How long does a connection request take to approve?',
      a: 'Most distributors respond within 1-2 business days. You\'ll receive a notification when your request is approved. You can also call the distributor directly to expedite the process.',
    ),
    _FaqItem(
      category: 'Account',
      icon: Icons.person_rounded,
      color: Color(0xFFD97706),
      q: 'How do I update my shop information?',
      a: 'Go to Profile → Shop Details or tap the edit icon (pen icon) at the top of your profile screen. Update the fields you need to change and tap "Save Changes".',
    ),
    _FaqItem(
      category: 'Account',
      icon: Icons.person_rounded,
      color: Color(0xFFD97706),
      q: 'How do I change my password?',
      a: 'Go to Profile → Change Password. Enter your current password, then your new password twice. Your password must be at least 8 characters and include a mix of letters and numbers.',
    ),
    _FaqItem(
      category: 'Account',
      icon: Icons.person_rounded,
      color: Color(0xFFD97706),
      q: 'Can I have multiple shops on one account?',
      a: 'Currently, each EasyStock account supports one shop. If you need to manage multiple shops, please contact support and we can help set up a business account.',
    ),
  ];

  List<_FaqItem> get _filtered {
    if (_query.isEmpty) return _faqs;
    final q = _query.toLowerCase();
    return _faqs
        .where((f) =>
            f.q.toLowerCase().contains(q) ||
            f.a.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList();
  }

  Map<String, List<(int, _FaqItem)>> get _grouped {
    final filtered = _filtered;
    final result = <String, List<(int, _FaqItem)>>{};
    for (var i = 0; i < filtered.length; i++) {
      result.putIfAbsent(filtered[i].category, () => []).add((i, filtered[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Help & FAQ'),
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.inter(
                        fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search help articles…',
                      hintStyle:
                          GoogleFonts.inter(fontSize: 14, color: textMuted),
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: textMuted),
                      suffixIcon: _query.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                              child: const Icon(Icons.close_rounded,
                                  size: 18, color: textMuted),
                            )
                          : null,
                      filled: true,
                      fillColor: surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                        borderSide:
                            const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                        borderSide:
                            const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                        borderSide: const BorderSide(
                            color: primaryNavy, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: grouped.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off_rounded,
                                  size: 40, color: textMuted),
                              const SizedBox(height: 12),
                              Text('No results for "$_query"',
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: textMuted)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                          children: grouped.entries.map((entry) {
                            final cat = entry.key;
                            final items = entry.value;
                            final sample = items.first.$2;
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Category header
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 16, 0, 8),
                                  child: Row(children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: sample.color
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(7),
                                      ),
                                      child: Icon(sample.icon,
                                          size: 14, color: sample.color),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(cat,
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary)),
                                  ]),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: surfaceWhite,
                                    borderRadius:
                                        BorderRadius.circular(cardRadius),
                                    border:
                                        Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    children: List.generate(items.length,
                                        (i) {
                                      final (idx, faq) = items[i];
                                      final isOpen =
                                          _expanded.contains(idx);
                                      return Column(children: [
                                        InkWell(
                                          onTap: () => setState(() {
                                            if (isOpen) {
                                              _expanded.remove(idx);
                                            } else {
                                              _expanded.add(idx);
                                            }
                                          }),
                                          borderRadius:
                                              BorderRadius.vertical(
                                            top: i == 0
                                                ? const Radius.circular(
                                                    cardRadius)
                                                : Radius.zero,
                                            bottom:
                                                i == items.length - 1 &&
                                                        !isOpen
                                                    ? const Radius.circular(
                                                        cardRadius)
                                                    : Radius.zero,
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                            child: Row(children: [
                                              Expanded(
                                                child: Text(faq.q,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isOpen
                                                          ? primaryNavy
                                                          : textPrimary,
                                                    )),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedRotation(
                                                turns:
                                                    isOpen ? 0.5 : 0,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: const Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    size: 20,
                                                    color: textMuted),
                                              ),
                                            ]),
                                          ),
                                        ),
                                        AnimatedSize(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          child: isOpen
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    color: bgColor,
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      bottom:
                                                          i == items.length - 1
                                                              ? const Radius
                                                                  .circular(
                                                                  cardRadius)
                                                              : Radius.zero,
                                                    ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16, 12, 16, 16),
                                                  child: Text(faq.a,
                                                      style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          color:
                                                              textSecondary,
                                                          height: 1.6)),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                        if (i < items.length - 1)
                                          const Divider(
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16,
                                              color: borderColor),
                                      ]);
                                    }),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.category,
    required this.icon,
    required this.color,
    required this.q,
    required this.a,
  });
  final String category, q, a;
  final IconData icon;
  final Color color;
}
