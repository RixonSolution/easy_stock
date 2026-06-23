import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import 'profile_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _form = GlobalKey<FormState>();

  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final rawPhone = auth.phone.startsWith('+92')
        ? auth.phone.substring(3)
        : auth.phone;
    _ownerNameCtrl = TextEditingController(text: auth.ownerName);
    _phoneCtrl     = TextEditingController(text: rawPhone);
    _emailCtrl     = TextEditingController(text: auth.email);
  }

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_ownerNameCtrl, _phoneCtrl, _emailCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updatePersonalInfo(
        ownerName: _ownerNameCtrl.text.trim(),
        phone:     '+92${_phoneCtrl.text.trim()}',
      );
      if (!mounted) return;
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
                        ctrl: _ownerNameCtrl,
                        label: 'Owner Name',
                        icon: Icons.person_outline_rounded,
                        hint: 'e.g. Muhammad Ali',
                        validator: nameValidator,
                      ),
                      ProfilePhoneField(controller: _phoneCtrl),
                      ProfileField(
                        ctrl: _emailCtrl,
                        label: 'Email Address',
                        icon: Icons.mail_outline_rounded,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        last: true,
                        validator: emailValidator,
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
