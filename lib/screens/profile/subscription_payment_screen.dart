import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

// ── Arg passed via router extra ───────────────────────────────────────────────
class SubscriptionPaymentArg {
  const SubscriptionPaymentArg({
    required this.planKey,
    required this.planLabel,
    required this.price,
    required this.billingMonths,
  });
  final String planKey, planLabel;
  final int price, billingMonths;

  String get priceLabel =>
      'Rs. ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  String get periodLabel => billingMonths == 12 ? '/year' : '/month';
}

// Support WhatsApp for billing
const _supportPhone = '923009641425';
const _supportName = 'EasyStock Billing';

// ── Screen ────────────────────────────────────────────────────────────────────
class SubscriptionPaymentScreen extends StatefulWidget {
  const SubscriptionPaymentScreen({super.key, required this.arg});
  final SubscriptionPaymentArg arg;

  @override
  State<SubscriptionPaymentScreen> createState() =>
      _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState
    extends State<SubscriptionPaymentScreen> {
  bool _launching = false;
  bool _whatsappOpened = false;
  bool _submitting = false;

  SubscriptionPaymentArg get _a => widget.arg;

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

  Future<void> _openWhatsApp() async {
    setState(() => _launching = true);

    final auth = context.read<AuthProvider>();

    final message = 'Assalam-o-Alaikum! 🙏\n\n'
        'I have made the payment for my EasyStock subscription.\n\n'
        '👤 *Account Details*\n'
        '• Owner: *${auth.ownerName}*\n'
        '• Shop: *${auth.shopName}*\n'
        '• Phone: *${auth.phone}*\n'
        '• Ref No: *${auth.referenceNumber}*\n\n'
        '💳 *Payment Details*\n'
        '• Plan: *${_a.planLabel}*\n'
        '• Amount: *${_a.priceLabel}${_a.periodLabel}*\n\n'
        'Please find the payment screenshot attached and activate my plan.\n\n'
        'JazakAllah Khair 🌸';

    final waUri = Uri.parse(
        'https://wa.me/$_supportPhone?text=${Uri.encodeComponent(message)}');

    setState(() => _launching = false);

    final opened =
        await launchUrl(waUri, mode: LaunchMode.externalApplication);

    if (!mounted) return;

    if (opened) {
      setState(() => _whatsappOpened = true);
    } else {
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: message));
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
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

  Future<void> _confirmSent() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final sub = context.read<SubscriptionProvider>();
      final txnId = 'MOB-${DateTime.now().millisecondsSinceEpoch}';

      final method = sub.paymentAccounts.isNotEmpty
          ? sub.paymentAccounts.first.title
          : 'WhatsApp';

      await sub.submitPayment(
        planKey: _a.planKey,
        txnId: txnId,
        method: method,
        userName: auth.shopName,
        ownerName: auth.ownerName,
        referenceNumber: auth.referenceNumber,
      );

      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not save payment record. Try again.',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: dangerText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final accounts = sub.paymentAccounts;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Navy header
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
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: Colors.white),
                        onPressed: () => context.pop(false),
                      ),
                      const Expanded(
                        child: Text('Plan Payment',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(pillRadius),
                        ),
                        child: Text(
                          _a.billingMonths == 12 ? 'Yearly' : 'Monthly',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      child: Row(children: [
                        const Icon(Icons.workspace_premium_rounded,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 10),
                        Text(_a.planLabel,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.white70)),
                        const Spacer(),
                        Text(_a.priceLabel,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(_a.periodLabel,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.white54)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable body
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
                          Text('How to Activate Your Plan',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: infoText)),
                        ]),
                        const SizedBox(height: 8),
                        ...[
                          '1. Copy an account number below and transfer ${_a.priceLabel}${_a.periodLabel}',
                          '2. Take a screenshot of the payment confirmation',
                          '3. Send the screenshot to EasyStock Billing via WhatsApp',
                          '4. Tap "I\'ve Paid" — we\'ll activate your plan within a few hours',
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

                  if (accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded,
                            color: textMuted, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Payment accounts not configured yet. Contact EasyStock billing via WhatsApp below.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: textSecondary, height: 1.4),
                          ),
                        ),
                      ]),
                    )
                  else
                    ...accounts.map((acc) => _PaymentCard(
                          account: acc,
                          onCopy: _copy,
                        )),

                  const SizedBox(height: 20),

                  _SectionLabel('SEND PAYMENT PROOF'),
                  const SizedBox(height: 10),

                  _WhatsAppContactCard(
                    name: _supportName,
                    phone: '+92 300 9641 425',
                    opened: _whatsappOpened,
                    onTap: _launching ? null : _openWhatsApp,
                  ),

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
                            'Screenshot sent! Tap "I\'ve Paid" below. '
                            'EasyStock will verify and activate your plan within a few hours.',
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

      // Bottom CTA
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
            ? ElevatedButton.icon(
                onPressed: _submitting ? null : _confirmSent,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(
                  _submitting ? 'Saving…' : "I've Paid — Waiting for Activation",
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              )
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
                  _launching ? 'Opening…' : 'Send Payment Screenshot via WhatsApp',
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
  final PaymentAccount account;
  final void Function(String, String) onCopy;

  Color get _color => switch (account.type) {
        'easypaisa' => const Color(0xFF1A8A5A),
        'jazzcash' => const Color(0xFFD97706),
        _ => const Color(0xFF185FA5),
      };

  Color get _bg => switch (account.type) {
        'easypaisa' => const Color(0xFFEAF8F2),
        'jazzcash' => const Color(0xFFFFF8ED),
        _ => const Color(0xFFEEF2F8),
      };

  IconData get _icon => account.type == 'bank'
      ? Icons.account_balance_rounded
      : Icons.phone_android_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: _bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(_icon, color: _color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary)),
                  if (account.accountName.isNotEmpty)
                    Text(account.accountName,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: textSecondary)),
                ],
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: borderColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Number',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: textMuted)),
                  const SizedBox(height: 2),
                  Text(account.accountNumber,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryNavy,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
            _CopyBtn(
                onTap: () => onCopy(
                    account.accountNumber, '${account.title} number')),
          ]),
        ),
        if (account.type == 'bank') ...[
          if (account.bankName.isNotEmpty)
            _ExtraRow('Bank', account.bankName, onCopy),
          if (account.iban.isNotEmpty)
            _ExtraRow('IBAN', account.iban, onCopy),
        ],
      ]),
    );
  }
}

class _ExtraRow extends StatelessWidget {
  const _ExtraRow(this.label, this.value, this.onCopy);
  final String label, value;
  final void Function(String, String) onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Divider(height: 1, color: borderColor),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(children: [
          Text('$label:',
              style:
                  GoogleFonts.inter(fontSize: 12, color: textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary)),
          ),
          _CopyBtn(small: true, onTap: () => onCopy(value, label)),
        ]),
      ),
    ]);
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
              size: widget.small ? 12 : 14,
              color: _copied ? successText : textSecondary),
          const SizedBox(width: 4),
          Text(_copied ? 'Copied' : 'Copy',
              style: GoogleFonts.inter(
                  fontSize: widget.small ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: _copied ? successText : textSecondary)),
        ]),
      ),
    );
  }
}

// ── WhatsApp contact card ─────────────────────────────────────────────────────
class _WhatsAppContactCard extends StatelessWidget {
  const _WhatsAppContactCard({
    required this.name,
    required this.phone,
    required this.opened,
    required this.onTap,
  });
  final String name, phone;
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
        child: Row(children: [
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
                Text(name,
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
        ]),
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
