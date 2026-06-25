import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgCtrl = TextEditingController();
  String _subject = 'Order Issue';
  bool _sending = false;

  static const _whatsappNumber = '923001234000';
  static const _supportEmail   = 'support@easystock.pk';
  static const _supportPhone   = '+92 300 1234 000';

  static const _subjects = [
    'Order Issue',
    'Payment Problem',
    'Wholesaler Issue',
    'Account & Profile',
    'App Bug / Error',
    'Subscription',
    'Other',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final msg = Uri.encodeComponent(
        'Assalam-o-Alaikum! I need help with: $_subject\n\n${_msgCtrl.text}');
    final uri = Uri.parse('https://wa.me/$_whatsappNumber?text=$msg');
    final opened =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: _supportPhone));
      messenger.showSnackBar(SnackBar(
        content: Text('WhatsApp not found. Number copied!',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: warningText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
      ));
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'EasyStock Support: $_subject',
        'body': _msgCtrl.text,
      },
    );
    final opened = await launchUrl(uri);
    if (!opened && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(text: _supportEmail));
      messenger.showSnackBar(SnackBar(
        content: Text('Email app not found. Address copied!',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: warningText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
      ));
    }
  }

  Future<void> _submitTicket() async {
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please describe your issue first.',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: dangerText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
      ));
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _sending = false);
    _msgCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Support ticket submitted! We\'ll reply within 24 hrs.',
              style: GoogleFonts.inter(fontSize: 13)),
        ),
      ]),
      backgroundColor: successText,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius)),
      duration: const Duration(seconds: 4),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Contact Support'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick contact options
                  _SectionLabel('REACH US DIRECTLY'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: _ContactBtn(
                        icon: Icons.chat_rounded,
                        label: 'WhatsApp',
                        color: const Color(0xFF1A8A5A),
                        bg: const Color(0xFFEAF8F2),
                        onTap: _openWhatsApp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ContactBtn(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        color: infoText,
                        bg: infoBg,
                        onTap: _sendEmail,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 8),

                  // Contact info row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 16, color: textMuted),
                      const SizedBox(width: 8),
                      Text('Support hours: ',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: textSecondary)),
                      Text('Mon–Sat, 9AM–6PM',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  _SectionLabel('SUBMIT A TICKET'),
                  const SizedBox(height: 10),

                  // Subject dropdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subject',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSecondary)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _subject,
                          onChanged: (v) =>
                              setState(() => _subject = v ?? _subject),
                          style: GoogleFonts.inter(
                              fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: textSecondary),
                            filled: true,
                            fillColor: bgColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide:
                                  const BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide:
                                  const BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide: const BorderSide(
                                  color: primaryNavy, width: 1.5),
                            ),
                          ),
                          items: _subjects
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s)))
                              .toList(),
                        ),

                        const SizedBox(height: 14),

                        Text('Describe your issue',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textSecondary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _msgCtrl,
                          maxLines: 5,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            hintText:
                                'Please describe the issue in detail. Include order IDs or screenshots if possible…',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: textMuted),
                            filled: true,
                            fillColor: bgColor,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide:
                                  const BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide:
                                  const BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(buttonRadius),
                              borderSide: const BorderSide(
                                  color: primaryNavy, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sending ? null : _submitTicket,
                            icon: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.send_rounded, size: 18),
                            label: Text(
                                _sending ? 'Submitting…' : 'Submit Ticket',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
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

// ── Quick contact button ──────────────────────────────────────────────────────
class _ContactBtn extends StatelessWidget {
  const _ContactBtn({
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.8));
}
