import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../providers/registration_provider.dart';

class Step3Review extends StatelessWidget {
  const Step3Review({super.key, required this.onSubmit});
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegistrationProvider>();

    final docs = [
      ('Shop Photo', reg.shopPhoto != null),
      ('Business Card', reg.businessCard != null),
      ('CNIC Front', reg.cnicFront != null),
    ];

    final allDocs = docs.every((d) => d.$2);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Application',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirm your details before submitting.',
            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 28),

          // Shop details card
          _Card(
            title: 'Shop Details',
            child: Column(
              children: [
                _DetailRow(label: 'Shop Name',  value: reg.shopName),
                _DetailRow(label: 'Owner',      value: reg.ownerName),
                _DetailRow(label: 'Phone',      value: reg.phone),
                if (reg.email.isNotEmpty)
                  _DetailRow(label: 'Email',    value: reg.email),
                _DetailRow(label: 'City',       value: reg.city, last: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Documents checklist card
          _Card(
            title: 'Documents',
            child: Column(
              children: List.generate(docs.length, (i) {
                final (label, done) = docs[i];
                return _DocRow(
                  label: label,
                  done: done,
                  last: i == docs.length - 1,
                );
              }),
            ),
          ),

          if (!allDocs) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningBg,
                borderRadius: BorderRadius.circular(pillRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: warningText, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload all documents to enable submission.',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: warningText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          Opacity(
            opacity: allDocs ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: allDocs
                  ? () async {
                      if (reg.isSubmitting) return;
                      await onSubmit();
                    }
                  : null,
              child: reg.isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Submit Application'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
                letterSpacing: 0.4,
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: textSecondary)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textPrimary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 16, color: borderColor),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  const _DocRow({
    required this.label,
    required this.done,
    this.last = false,
  });
  final String label;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: textPrimary)),
              ),
              Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.cancel_outlined,
                    size: 16,
                    color: done ? successText : dangerText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    done ? 'Uploaded' : 'Missing',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: done ? successText : dangerText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 16, color: borderColor),
      ],
    );
  }
}
