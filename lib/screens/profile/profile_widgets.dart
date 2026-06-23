// Shared widgets used across all profile sub-screens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';

// ── Navy sub-header with back button ─────────────────────────────────────────
class ProfileSubHeader extends StatelessWidget {
  const ProfileSubHeader({super.key, required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            ...?actions,
          ]),
        ),
      ),
    );
  }
}

// ── Bottom save bar ───────────────────────────────────────────────────────────
class ProfileSaveBar extends StatelessWidget {
  const ProfileSaveBar({
    super.key,
    required this.saving,
    required this.onSave,
    this.label = 'Save Changes',
  });
  final bool saving;
  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: surfaceWhite,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: ElevatedButton(
        onPressed: saving ? null : onSave,
        style:
            ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Card wrapper ──────────────────────────────────────────────────────────────
class ProfileFormCard extends StatelessWidget {
  const ProfileFormCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: borderColor),
        ),
        child: Column(children: children),
      );
}

// ── Text field row inside card ────────────────────────────────────────────────
class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.last = false,
    this.obscure = false,
    this.readOnly = false,
    this.suffix,
    this.onChanged,
  });
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool last, obscure, readOnly;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            obscureText: obscure,
            readOnly: readOnly,
            validator: validator,
            onChanged: onChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: readOnly ? textSecondary : textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: textMuted),
              prefixIcon: Icon(icon, size: 18, color: textSecondary),
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline_rounded,
                      size: 16, color: textMuted)
                  : suffix,
              filled: true,
              fillColor: readOnly ? const Color(0xFFF0F2F5) : bgColor,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
                borderSide:
                    const BorderSide(color: primaryNavy, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
                borderSide: const BorderSide(color: dangerText),
              ),
            ),
          ),
        ),
        if (!last)
          const Divider(
              height: 1, indent: 16, endIndent: 16, color: borderColor),
      ],
    );
  }
}

String? requiredValidator(String? v) =>
    (v == null || v.trim().isEmpty) ? 'This field is required' : null;

String? nameValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'This field is required';
  if (v.trim().length < 2) return 'Must be at least 2 characters';
  if (!RegExp(r"^[a-zA-Z\s؀-ۿ]+$").hasMatch(v.trim())) {
    return 'Name should contain letters only';
  }
  return null;
}

String? emailValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email address is required';
  if (!RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$')
      .hasMatch(v.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

String? addressValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'This field is required';
  if (v.trim().length < 10) return 'Please enter a more detailed address';
  return null;
}

// ── Pakistan phone field (+92 prefix) — fits inside ProfileFormCard ───────────
class ProfilePhoneField extends StatelessWidget {
  /// [controller] holds only the 10-digit number (no +92 prefix).
  /// Strip "+92" from any stored value before passing it in.
  const ProfilePhoneField({
    super.key,
    required this.controller,
    this.last = false,
  });

  final TextEditingController controller;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            'Phone Number',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: FormField<String>(
            initialValue: controller.text,
            validator: (_) {
              final digits = controller.text.trim();
              if (digits.isEmpty) return 'Phone number is required';
              if (!RegExp(r'^3[0-9]{9}$').hasMatch(digits)) {
                return 'Enter 10 digits starting with 3 (e.g. 3001234567)';
              }
              return null;
            },
            builder: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(buttonRadius),
                    border: Border.all(
                      color: state.hasError ? dangerText : borderColor,
                      width: state.hasError ? 1.0 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Country code prefix
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 13),
                        decoration: BoxDecoration(
                          color: surfaceWhite,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(buttonRadius),
                            bottomLeft: Radius.circular(buttonRadius),
                          ),
                          border: const Border(
                            right: BorderSide(color: borderColor),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇵🇰',
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '+92',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Digit input
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (_) => state.didChange(controller.text),
                          style: GoogleFonts.inter(
                              fontSize: 14, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: '3001234567',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 13, color: textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 13),
                            errorStyle: const TextStyle(height: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 2),
                    child: Text(
                      'Enter number without leading 0 (e.g. 3001234567)',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: textMuted),
                    ),
                  ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 2),
                    child: Text(
                      state.errorText!,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: dangerText),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (!last)
          const Divider(height: 1, indent: 16, endIndent: 16, color: borderColor),
      ],
    );
  }
}
