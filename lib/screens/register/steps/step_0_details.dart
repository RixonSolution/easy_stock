import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../providers/registration_provider.dart';

class Step0Details extends StatefulWidget {
  const Step0Details({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<Step0Details> createState() => _Step0DetailsState();
}

class _Step0DetailsState extends State<Step0Details> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _shopName;
  late final TextEditingController _ownerName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPass;
  late final TextEditingController _address;
  late final TextEditingController _cityCtrl;

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final p = context.read<RegistrationProvider>();
    _shopName    = TextEditingController(text: p.shopName);
    _ownerName   = TextEditingController(text: p.ownerName);
    final rawPhone = p.phone.startsWith('+92') ? p.phone.substring(3) : p.phone;
    _phone       = TextEditingController(text: rawPhone);
    _email       = TextEditingController(text: p.email);
    _password    = TextEditingController(text: p.password);
    _confirmPass = TextEditingController(text: p.password);
    _address     = TextEditingController(text: p.address);
    _cityCtrl    = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    _shopName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPass.dispose();
    _address.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final p = context.read<RegistrationProvider>();
    p.setField('shopName',  _shopName.text.trim());
    p.setField('ownerName', _ownerName.text.trim());
    p.setField('phone',     '+92${_phone.text.trim()}');
    p.setField('email',     _email.text.trim());
    p.setField('password',  _password.text);
    p.setField('address',   _address.text.trim());
    p.setField('city',      _cityCtrl.text.trim());
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _save();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Details',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tell us about your shop so wholesalers can find you.',
              style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 28),

            // ── Shop Name ──────────────────────────────────────────────
            _FieldLabel('Shop Name'),
            const SizedBox(height: 6),
            _InputField(
              controller: _shopName,
              hint: 'e.g. Al-Noor Paint Store',
              icon: Icons.storefront_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Shop name is required';
                if (v.trim().length < 2) return 'Must be at least 2 characters';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Owner Name ─────────────────────────────────────────────
            _FieldLabel('Owner Name'),
            const SizedBox(height: 6),
            _InputField(
              controller: _ownerName,
              hint: 'e.g. Muhammad Ali',
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Owner name is required';
                if (v.trim().length < 2) return 'Must be at least 2 characters';
                final onlyLetters = RegExp(r"^[a-zA-Z\s؀-ۿ]+$");
                if (!onlyLetters.hasMatch(v.trim())) {
                  return 'Name should contain letters only';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Phone ──────────────────────────────────────────────────
            _FieldLabel('Phone Number'),
            const SizedBox(height: 6),
            _PhoneField(controller: _phone),

            const SizedBox(height: 16),

            // ── Email ──────────────────────────────────────────────────
            _FieldLabel('Email Address'),
            const SizedBox(height: 6),
            _InputField(
              controller: _email,
              hint: 'yourshop@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email address is required';
                }
                if (!RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(v.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Password ───────────────────────────────────────────────
            _FieldLabel('Password'),
            const SizedBox(height: 6),
            _InputField(
              controller: _password,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePass,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: textSecondary,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Must be at least 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(v)) {
                  return 'Include at least one uppercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(v)) {
                  return 'Include at least one number';
                }
                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                  return 'Include at least one special character';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Confirm Password ───────────────────────────────────────
            _FieldLabel('Confirm Password'),
            const SizedBox(height: 6),
            _InputField(
              controller: _confirmPass,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffix: GestureDetector(
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: textSecondary,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _password.text) return 'Passwords do not match';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Shop Address ───────────────────────────────────────────
            _FieldLabel('Shop Address'),
            const SizedBox(height: 6),
            _InputField(
              controller: _address,
              hint: 'e.g. Shop #12, Anarkali Bazar, Near Masjid',
              icon: Icons.location_on_outlined,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Shop address is required';
                if (v.trim().length < 10) return 'Please enter a more detailed address';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── City ───────────────────────────────────────────────────
            _FieldLabel('City'),
            const SizedBox(height: 6),
            _InputField(
              controller: _cityCtrl,
              hint: 'e.g. Lahore',
              icon: Icons.location_city_outlined,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'City is required';
                return null;
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );
  }
}

// ── Generic input field ───────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ??
          (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: textMuted),
        prefixIcon: Icon(icon, color: textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 15,
        ),
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
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: dangerText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: dangerText, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 11, color: dangerText),
      ),
    );
  }
}

// ── Pakistan phone field (+92 prefix) ────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (_) {
        final digits = controller.text.trim();
        if (digits.isEmpty) return 'Phone number is required';
        if (!RegExp(r'^3[0-9]{9}$').hasMatch(digits)) {
          return 'Enter 10 digits starting with 3 (e.g. 3001234567)';
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
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
                        horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(buttonRadius),
                        bottomLeft: Radius.circular(buttonRadius),
                      ),
                      border: Border(
                        right: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇵🇰', style: const TextStyle(fontSize: 18)),
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

                  // Number input
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
                        hintStyle:
                            GoogleFonts.inter(fontSize: 13, color: textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 15),
                        errorStyle: const TextStyle(height: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Helper text
            if (!state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4),
                child: Text(
                  'Enter number without leading 0 (e.g. 3001234567)',
                  style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                ),
              ),

            // Error text
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 4),
                child: Text(
                  state.errorText!,
                  style: GoogleFonts.inter(fontSize: 11, color: dangerText),
                ),
              ),
          ],
        );
      },
    );
  }
}
