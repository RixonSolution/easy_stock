import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class ShopDetailsScreen extends StatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final _form = GlobalKey<FormState>();

  final _shopNameCtrl = TextEditingController(text: 'Al-Kareem Paint Store');
  final _ntnCtrl      = TextEditingController(text: '1234567-8');
  final _addressCtrl  = TextEditingController(text: '45-B, Main Boulevard, Gulberg III');
  final _cityCtrl     = TextEditingController(text: 'Lahore');
  final _provinceCtrl = TextEditingController(text: 'Punjab');

  String _shopType = 'Paint Store';
  bool _saving = false;

  static const _shopTypes = [
    'Paint Store',
    'Ply Store',
    'Hardware Store',
    'General Trade',
  ];

  @override
  void dispose() {
    for (final c in [
      _shopNameCtrl, _ntnCtrl, _addressCtrl, _cityCtrl, _provinceCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text('Shop details saved!', style: GoogleFonts.inter(fontSize: 13)),
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
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Shop Details'),
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileFormCard(children: [
                      ProfileField(
                        ctrl: _shopNameCtrl,
                        label: 'Shop Name',
                        icon: Icons.storefront_rounded,
                        hint: 'Your shop name',
                        validator: requiredValidator,
                      ),
                      // Shop type dropdown
                      _DropdownRow(
                        label: 'Shop Type',
                        icon: Icons.category_outlined,
                        value: _shopType,
                        items: _shopTypes,
                        onChanged: (v) =>
                            setState(() => _shopType = v ?? _shopType),
                      ),
                      ProfileField(
                        ctrl: _ntnCtrl,
                        label: 'NTN / Registration No.',
                        icon: Icons.badge_outlined,
                        hint: '1234567-8',
                        keyboardType: TextInputType.number,
                      ),
                      ProfileField(
                        ctrl: _addressCtrl,
                        label: 'Shop Address',
                        icon: Icons.location_on_outlined,
                        hint: 'Street, Area',
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _cityCtrl,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        hint: 'e.g. Lahore',
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _provinceCtrl,
                        label: 'Province',
                        icon: Icons.map_outlined,
                        hint: 'e.g. Punjab',
                        last: true,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: successBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: successText.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.verified_rounded,
                            color: successText, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shop Verified',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: successText)),
                              Text(
                                  'Your shop has been verified by EasyStock.',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: successText)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProfileSaveBar(saving: _saving, onSave: _save),
    );
  }
}

// ── Inline dropdown row ───────────────────────────────────────────────────────
class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label, value;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

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
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 14, color: textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: textSecondary),
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
            ),
            items: items
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
          ),
        ),
        const Divider(
            height: 1, indent: 16, endIndent: 16, color: borderColor),
      ],
    );
  }
}
