import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Terms & Privacy'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last updated banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: infoBg,
                      borderRadius: BorderRadius.circular(buttonRadius),
                      border: Border.all(
                          color: infoText.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.update_rounded,
                          size: 15, color: infoText),
                      const SizedBox(width: 8),
                      Text('Last updated: 1 January 2026',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: infoText)),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  ..._sections.map((s) => _Section(s)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section(this.data);
  final _SectionData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primaryNavy)),
          const SizedBox(height: 8),
          Text(data.body,
              style: GoogleFonts.inter(
                  fontSize: 13, color: textSecondary, height: 1.7)),
        ],
      ),
    );
  }
}

class _SectionData {
  const _SectionData(this.title, this.body);
  final String title, body;
}

const _sections = [
  _SectionData(
    '1. Acceptance of Terms',
    'By downloading, installing, or using the EasyStock mobile application ("App"), you agree to be bound by these Terms & Conditions. If you do not agree to any part of these terms, you may not use our App.\n\nThese terms apply to all users of the App, including retailers, wholesalers, and any other individuals who access the platform.',
  ),
  _SectionData(
    '2. Description of Service',
    'EasyStock is a business management platform designed for retailers to manage stock orders, connect with wholesalers, and track deliveries. The App facilitates communication between retailers and wholesalers but does not itself sell or deliver goods.\n\nWe reserve the right to modify, suspend, or discontinue any part of the service at any time without notice.',
  ),
  _SectionData(
    '3. User Accounts',
    'You must create an account to use EasyStock. You are responsible for:\n• Maintaining the confidentiality of your login credentials\n• All activities that occur under your account\n• Providing accurate and complete registration information\n• Promptly updating your information if it changes\n\nYou may not share your account credentials or transfer your account to another person.',
  ),
  _SectionData(
    '4. Privacy Policy',
    'We collect the following information to operate the App:\n• Personal details (name, CNIC, phone number, email)\n• Shop information (name, address, NTN number)\n• Order and transaction history\n• Device information and usage data\n\nYour data is encrypted and stored securely. We do not sell your personal information to third parties. Your data may be shared with wholesalers only to the extent necessary to fulfil your orders.',
  ),
  _SectionData(
    '5. Payments & Transactions',
    'EasyStock facilitates payment coordination between retailers and wholesalers. All payments are made directly between users via third-party services (EasyPaisa, JazzCash, bank transfer). EasyStock is not a payment processor and is not responsible for:\n• Failed or delayed transfers\n• Disputes between retailers and wholesalers\n• Errors in payment amounts\n\nAlways verify payment receipt confirmations before processing orders.',
  ),
  _SectionData(
    '6. Prohibited Activities',
    'You may not use EasyStock to:\n• Provide false information or impersonate another person\n• Engage in fraudulent transactions\n• Harass, abuse, or threaten other users\n• Attempt to gain unauthorized access to any account or system\n• Use the App for any unlawful purpose\n\nViolation of these rules may result in immediate account suspension.',
  ),
  _SectionData(
    '7. Intellectual Property',
    'All content, trademarks, logos, and intellectual property in the EasyStock App are owned by Rixon Solution. You may not copy, modify, distribute, or use our intellectual property without written permission.\n\nUser-generated content (such as order details and shop information) remains the property of the respective users.',
  ),
  _SectionData(
    '8. Limitation of Liability',
    'EasyStock and Rixon Solution shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App. Our maximum liability to you shall not exceed the subscription fees paid by you in the three months preceding the claim.',
  ),
  _SectionData(
    '9. Contact',
    'For questions about these Terms & Privacy Policy, please contact:\n\nEmail: legal@easystock.pk\nPhone: +92 300 1234 000\nAddress: Rixon Solution, Lahore, Pakistan',
  ),
];

