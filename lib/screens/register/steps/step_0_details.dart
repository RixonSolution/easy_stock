import 'package:flutter/material.dart';
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
  late final TextEditingController _city;

  @override
  void initState() {
    super.initState();
    final p = context.read<RegistrationProvider>();
    _shopName  = TextEditingController(text: p.shopName);
    _ownerName = TextEditingController(text: p.ownerName);
    _phone     = TextEditingController(text: p.phone);
    _email     = TextEditingController(text: p.email);
    _city      = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    _shopName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  void _save() {
    final p = context.read<RegistrationProvider>();
    p.setField('shopName',  _shopName.text.trim());
    p.setField('ownerName', _ownerName.text.trim());
    p.setField('phone',     _phone.text.trim());
    p.setField('email',     _email.text.trim());
    p.setField('city',      _city.text.trim());
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
              'Tell us about your shop so distributors can find you.',
              style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 28),
            _Field(
              controller: _shopName,
              hint: 'Shop Name',
              icon: Icons.storefront_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _ownerName,
              hint: 'Owner Name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _phone,
              hint: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _email,
              hint: 'Email Address (optional)',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              required: false,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _city,
              hint: 'City',
              icon: Icons.location_city_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _continue,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.required = true,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(buttonRadius),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: textMuted),
          prefixIcon: Icon(icon, color: textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          errorStyle: GoogleFonts.inter(fontSize: 11, color: dangerText),
        ),
      ),
    );
  }
}
