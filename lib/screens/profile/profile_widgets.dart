// Shared widgets used across all profile sub-screens
import 'package:flutter/material.dart';
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
    this.suffix,
    this.onChanged,
  });
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool last, obscure;
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
            validator: validator,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: textMuted),
              prefixIcon: Icon(icon, size: 18, color: textSecondary),
              suffixIcon: suffix,
              filled: true,
              fillColor: bgColor,
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
