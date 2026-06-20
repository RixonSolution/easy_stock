import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _form = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController(text: 'Ammar Shabbir');
  final _cnicCtrl     = TextEditingController(text: '35202-1234567-1');
  final _phoneCtrl    = TextEditingController(text: '+92 300 1234567');
  final _emailCtrl    = TextEditingController(text: 'ammar@alkareem.pk');
  final _dobCtrl      = TextEditingController(text: '15 March 1995');

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl, _cnicCtrl, _phoneCtrl, _emailCtrl, _dobCtrl
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
        Text('Personal info updated!',
            style: GoogleFonts.inter(fontSize: 13)),
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
          const ProfileSubHeader(title: 'Personal Info'),
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    ProfileFormCard(children: [
                      ProfileField(
                        ctrl: _fullNameCtrl,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        hint: 'Your legal full name',
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _cnicCtrl,
                        label: 'CNIC Number',
                        icon: Icons.credit_card_outlined,
                        hint: 'XXXXX-XXXXXXX-X',
                        keyboardType: TextInputType.number,
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _phoneCtrl,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        hint: '+92 3XX XXXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _emailCtrl,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      ProfileField(
                        ctrl: _dobCtrl,
                        label: 'Date of Birth',
                        icon: Icons.cake_outlined,
                        hint: 'DD Month YYYY',
                        last: true,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: infoBg,
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                            color: infoText.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: infoText, size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your personal information is encrypted and only used for account verification. It is never shared with distributors.',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: infoText,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
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
