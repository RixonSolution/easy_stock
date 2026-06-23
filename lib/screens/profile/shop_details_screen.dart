import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import 'profile_widgets.dart';

class ShopDetailsScreen extends StatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final rawPhone = auth.phone.startsWith('+92')
        ? auth.phone.substring(3)
        : auth.phone;
    _shopNameCtrl = TextEditingController(text: auth.shopName);
    _phoneCtrl    = TextEditingController(text: rawPhone);
    _emailCtrl    = TextEditingController(text: auth.email);
    _addressCtrl  = TextEditingController(text: auth.address);
    _cityCtrl     = TextEditingController(text: auth.city);
  }

  bool _saving = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateShopDetails(
        shopName: _shopNameCtrl.text.trim(),
        phone:    '+92${_phoneCtrl.text.trim()}',
        address:  _addressCtrl.text.trim(),
        city:     _cityCtrl.text.trim(),
      );
      if (!mounted) return;
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save. Please try again.',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: dangerText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius)),
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                        hint: 'e.g. Al-Noor Paint Store',
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Shop name is required';
                          }
                          if (v.trim().length < 2) {
                            return 'Must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      ProfilePhoneField(controller: _phoneCtrl),
                      ProfileField(
                        ctrl: _emailCtrl,
                        label: 'Email Address',
                        icon: Icons.mail_outline_rounded,
                        hint: 'yourshop@email.com',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        validator: emailValidator,
                      ),
                      ProfileField(
                        ctrl: _addressCtrl,
                        label: 'Shop Address',
                        icon: Icons.location_on_outlined,
                        hint: 'e.g. Shop #12, Anarkali Bazar',
                        validator: addressValidator,
                      ),
                      ProfileField(
                        ctrl: _cityCtrl,
                        label: 'City',
                        icon: Icons.location_city_outlined,
                        hint: 'e.g. Lahore',
                        validator: requiredValidator,
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
