import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/theme.dart';

// ── Arg passed via router extra ───────────────────────────────────────────────
class PaymentArg {
  const PaymentArg({
    required this.orderId,
    required this.distributorName,
    required this.distributorPhone,
    required this.total,
    required this.totalAmount,
    required this.itemCount,
  });
  final String orderId, distributorName, distributorPhone, total;
  final int totalAmount, itemCount;
}

// ── Payment account model ─────────────────────────────────────────────────────
class _PayAccount {
  const _PayAccount({
    required this.method,
    required this.accountName,
    required this.number,
    required this.icon,
    required this.color,
    required this.bg,
    this.extra,
  });
  final String method, accountName, number;
  final IconData icon;
  final Color color, bg;
  final List<_ExtraField>? extra;
}

class _ExtraField {
  const _ExtraField(this.label, this.value);
  final String label, value;
}

// Mock payment accounts for "Pak Paints"
const _accounts = [
  _PayAccount(
    method: 'EasyPaisa',
    accountName: 'Muhammad Ali (Pak Paints)',
    number: '0300-1234567',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF1A8A5A),
    bg: Color(0xFFEAF8F2),
  ),
  _PayAccount(
    method: 'JazzCash',
    accountName: 'Muhammad Ali (Pak Paints)',
    number: '0321-7654321',
    icon: Icons.phone_android_rounded,
    color: Color(0xFFD97706),
    bg: Color(0xFFFFF8ED),
  ),
  _PayAccount(
    method: 'Bank Transfer',
    accountName: 'Pak Paints Trading Co.',
    number: '0123-4567890-123',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF185FA5),
    bg: Color(0xFFEEF2F8),
    extra: [
      _ExtraField('Bank', 'Meezan Bank'),
      _ExtraField('Branch', 'Gulberg III, Lahore'),
      _ExtraField('IBAN', 'PK36MEZN0001234567890'),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key, required this.arg});
  final PaymentArg arg;

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  bool _launching = false;
  bool _whatsappOpened = false;

  PaymentArg get _a => widget.arg;

  // ── Copy helper ────────────────────────────────────────────────────────────
  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('$label copied', style: GoogleFonts.inter(fontSize: 13)),
      ]),
      backgroundColor: primaryNavy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Open WhatsApp directly ─────────────────────────────────────────────────
  Future<void> _openWhatsApp() async {
    setState(() => _launching = true);

    // Normalise phone to international format (Pakistan)
    final digits = _a.distributorPhone.replaceAll(RegExp(r'\D'), '');
    final phone = digits.startsWith('92') ? digits : '92${digits.substring(1)}';

    final message =
        'Assalam-o-Alaikum! 🙏\n\n'
        'I have made the payment for Order *${_a.orderId}*.\n\n'
        '💰 Amount: *${_a.total}*\n'
        '📦 Items: ${_a.itemCount} items\n\n'
        'Please find the payment screenshot attached and confirm the order.\n\n'
        'JazakAllah Khair 🌸';

    final waUri = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    setState(() => _launching = false);

    final opened =
        await launchUrl(waUri, mode: LaunchMode.externalApplication);

    if (!mounted) return;

    if (opened) {
      setState(() => _whatsappOpened = true);
    } else {
      // Fallback: copy message so user can paste manually
      await Clipboard.setData(ClipboardData(text: message));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'WhatsApp not found. Message copied — paste it manually.',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: dangerText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
        duration: const Duration(seconds: 4),
      ));
    }
  }

  // ── Confirm payment sent ───────────────────────────────────────────────────
  void _confirmSent() {
    context.pop(true); // tracking screen advances status to payment_submitted
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: Colors.white),
                          onPressed: () => context.pop(false),
                        ),
                        Expanded(
                          child: Text('Make Payment',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: accentOrange.withValues(alpha: 0.18),
                            borderRadius:
                                BorderRadius.circular(pillRadius),
                          ),
                          child: Text(_a.orderId,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accentOrange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Order summary strip
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              color: Colors.white54, size: 16),
                          const SizedBox(width: 8),
                          Text('${_a.itemCount} items  ·  ${_a.distributorName}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.white60)),
                          const Spacer(),
                          Text(_a.total,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // How-to steps
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: infoBg,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(
                          color: infoText.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              color: infoText, size: 16),
                          const SizedBox(width: 8),
                          Text('How to Pay',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: infoText)),
                        ]),
                        const SizedBox(height: 8),
                        ...[
                          '1. Copy an account number below and transfer the amount',
                          '2. Take a screenshot of the payment confirmation',
                          '3. Tap "Send Screenshot via WhatsApp" to open the wholesaler\'s chat',
                        ].map((s) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(s,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: infoText,
                                      height: 1.4)),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _SectionLabel('PAYMENT ACCOUNTS'),
                  const SizedBox(height: 10),

                  // Payment method cards
                  ..._accounts.map((acc) => _PaymentCard(
                        account: acc,
                        onCopy: _copy,
                      )),

                  const SizedBox(height: 20),

                  _SectionLabel('SEND PAYMENT PROOF'),
                  const SizedBox(height: 10),

                  // ── WhatsApp distributor card ──────────────────────────
                  _WhatsAppContactCard(
                    distributorName: _a.distributorName,
                    phone: _a.distributorPhone,
                    opened: _whatsappOpened,
                    onTap: _launching ? null : _openWhatsApp,
                  ),

                  // Hint after WhatsApp opened
                  if (_whatsappOpened) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: warningBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: warningText.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.schedule_rounded,
                            color: warningText, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Screenshot sent! Tap "I\'ve Sent It" below. '
                            'The wholesaler will confirm and your order status will update.',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: warningText,
                                height: 1.5),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ───────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 14,
        ),
        decoration: const BoxDecoration(
          color: surfaceWhite,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: _whatsappOpened
            // After WhatsApp opened — confirm button
            ? ElevatedButton.icon(
                onPressed: _confirmSent,
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text("I've Sent It — Waiting for Confirmation"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              )
            // Before WhatsApp — single green open button
            : ElevatedButton.icon(
                onPressed: _launching ? null : _openWhatsApp,
                icon: _launching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.chat_rounded, size: 20),
                label: Text(
                  _launching ? 'Opening…' : 'Send Screenshot via WhatsApp',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: const Color(0xFF1A8A5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonRadius)),
                ),
              ),
      ),
    );
  }
}

// ── Payment card ──────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.account, required this.onCopy});
  final _PayAccount account;
  final void Function(String text, String label) onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Method header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: account.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(account.icon, color: account.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.method,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary)),
                      Text(account.accountName,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderColor),

          // Account number
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Number',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(account.number,
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primaryNavy,
                            letterSpacing: 0.5)),
                  ],
                ),
                const Spacer(),
                _CopyBtn(
                  onTap: () =>
                      onCopy(account.number, '${account.method} number'),
                ),
              ],
            ),
          ),

          // Extra fields (bank details)
          if (account.extra != null) ...[
            const Divider(height: 1, color: borderColor),
            ...account.extra!.map((f) => Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Row(
                    children: [
                      Text('${f.label}:',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f.value,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textPrimary)),
                      ),
                      _CopyBtn(
                          small: true,
                          onTap: () => onCopy(f.value, f.label)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Copy button ───────────────────────────────────────────────────────────────
class _CopyBtn extends StatefulWidget {
  const _CopyBtn({required this.onTap, this.small = false});
  final VoidCallback onTap;
  final bool small;

  @override
  State<_CopyBtn> createState() => _CopyBtnState();
}

class _CopyBtnState extends State<_CopyBtn> {
  bool _copied = false;

  void _handle() async {
    widget.onTap();
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: widget.small ? 8 : 12,
            vertical: widget.small ? 4 : 8),
        decoration: BoxDecoration(
          color: _copied ? successBg : bgColor,
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(
              color: _copied
                  ? successText.withValues(alpha: 0.4)
                  : borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                _copied
                    ? Icons.check_rounded
                    : Icons.copy_rounded,
                size: widget.small ? 12 : 14,
                color: _copied ? successText : textSecondary),
            const SizedBox(width: 4),
            Text(_copied ? 'Copied' : 'Copy',
                style: GoogleFonts.inter(
                    fontSize: widget.small ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: _copied ? successText : textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── WhatsApp distributor contact card ─────────────────────────────────────────
class _WhatsAppContactCard extends StatelessWidget {
  const _WhatsAppContactCard({
    required this.distributorName,
    required this.phone,
    required this.opened,
    required this.onTap,
  });
  final String distributorName, phone;
  final bool opened;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: opened ? const Color(0xFFEAF8F2) : surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: opened
                ? const Color(0xFF1A8A5A).withValues(alpha: 0.4)
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            // WhatsApp green bubble
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1A8A5A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.chat_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opened ? 'WhatsApp Opened ✓' : 'WhatsApp',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: opened
                            ? const Color(0xFF1A8A5A)
                            : textMuted,
                        letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 2),
                  Text(distributorName,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary)),
                  const SizedBox(height: 1),
                  Text(phone,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: textSecondary)),
                ],
              ),
            ),
            // Animated icon: open-in-new → check
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: opened
                  ? const Icon(Icons.check_circle_rounded,
                      key: ValueKey('check'),
                      color: Color(0xFF1A8A5A),
                      size: 24)
                  : const Icon(Icons.open_in_new_rounded,
                      key: ValueKey('open'),
                      color: Color(0xFF1A8A5A),
                      size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
            letterSpacing: 0.8));
  }
}
