import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import 'profile_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();

  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool    _showCurrent = false;
  bool    _showNew     = false;
  bool    _showConfirm = false;
  bool    _saving      = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int _strength(String pw) {
    if (pw.isEmpty) return 0;
    int score = 0;
    if (pw.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[!@#\$&*~%^()_+=\-]').hasMatch(pw)) score++;
    return score;
  }

  Color _strengthColor(int s) {
    if (s <= 1) return dangerText;
    if (s == 2) return warningText;
    if (s == 3) return infoText;
    return successText;
  }

  String _strengthLabel(int s) {
    if (s <= 1) return 'Weak';
    if (s == 2) return 'Fair';
    if (s == 3) return 'Good';
    return 'Strong';
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final err = await context.read<AuthProvider>().changePassword(
      currentPassword: _currentCtrl.text,
      newPassword:     _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text('Password changed!', style: GoogleFonts.inter(fontSize: 13)),
      ]),
      backgroundColor: successText,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius)),
      duration: const Duration(seconds: 3),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength(_newCtrl.text);
    final sColor   = _strengthColor(strength);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Change Password'),
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    // Password fields card
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          _PwRow(
                            ctrl: _currentCtrl,
                            label: 'Current Password',
                            show: _showCurrent,
                            onToggle: () => setState(
                                () => _showCurrent = !_showCurrent),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Current password is required';
                              }
                              if (v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor),
                          _PwRow(
                            ctrl: _newCtrl,
                            label: 'New Password',
                            show: _showNew,
                            onToggle: () =>
                                setState(() => _showNew = !_showNew),
                            onChanged: (_) => setState(() {}),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'New password is required';
                              }
                              if (v.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                return 'Include at least one uppercase letter (A–Z)';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)) {
                                return 'Include at least one number (0–9)';
                              }
                              if (!RegExp(r'[!@#\$&*~%^()_+=\-]').hasMatch(v)) {
                                return 'Include at least one special character (!@#\$)';
                              }
                              if (v == _currentCtrl.text) {
                                return 'New password must be different from current password';
                              }
                              return null;
                            },
                          ),
                          const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: borderColor),
                          _PwRow(
                            ctrl: _confirmCtrl,
                            label: 'Confirm New Password',
                            show: _showConfirm,
                            onToggle: () => setState(
                                () => _showConfirm = !_showConfirm),
                            last: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (v != _newCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // Strength indicator
                    if (_newCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surfaceWhite,
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Password Strength',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textSecondary)),
                                Text(_strengthLabel(strength),
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sColor)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: strength / 4,
                                minHeight: 6,
                                backgroundColor: borderColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    sColor),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...[
                              ('At least 8 characters',
                                _newCtrl.text.length >= 8),
                              ('Uppercase letter (A–Z)',
                                RegExp(r'[A-Z]').hasMatch(_newCtrl.text)),
                              ('Number (0–9)',
                                RegExp(r'[0-9]').hasMatch(_newCtrl.text)),
                              ('Special character (!@#\$)',
                                RegExp(r'[!@#\$&*~%^()_+=\-]')
                                    .hasMatch(_newCtrl.text)),
                            ].map((r) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(children: [
                                    Icon(
                                      r.$2
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      size: 14,
                                      color:
                                          r.$2 ? successText : textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(r.$1,
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: r.$2
                                                ? textPrimary
                                                : textMuted)),
                                  ]),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dangerBg,
                  borderRadius: BorderRadius.circular(buttonRadius),
                  border: Border.all(color: dangerText.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: dangerText, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: dangerText)),
                  ),
                ]),
              ),
            ),
          ProfileSaveBar(
            saving: _saving,
            onSave: _save,
            label: 'Change Password',
          ),
        ],
      ),
    );
  }
}

// ── Password row ──────────────────────────────────────────────────────────────
class _PwRow extends StatelessWidget {
  const _PwRow({
    required this.ctrl,
    required this.label,
    required this.show,
    required this.onToggle,
    this.validator,
    this.onChanged,
    this.last = false,
  });
  final TextEditingController ctrl;
  final String label;
  final bool show, last;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            obscureText: !show,
            onChanged: onChanged,
            validator: validator,
            style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: textMuted),
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  size: 18, color: textSecondary),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                    show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: textSecondary),
              ),
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
        ],
      ),
    );
  }
}
