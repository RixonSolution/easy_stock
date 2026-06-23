import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import '../../utils/image_picker_helper.dart';
import 'profile_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();

  final _shopNameCtrl  = TextEditingController(text: 'Al-Kareem Paint Store');
  final _ownerNameCtrl = TextEditingController(text: 'Ammar Shabbir');
  final _phoneCtrl     = TextEditingController(text: '+92 300 1234567');
  final _emailCtrl     = TextEditingController(text: 'ammar@alkareem.pk');
  final _cityCtrl      = TextEditingController(text: 'Lahore, Pakistan');

  File? _pickedImage;
  bool _picking = false;
  bool _saving  = false;

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);

    // Show source chooser
    final source = await showModalBottomSheet<_ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _SourceSheet(),
    );

    if (!mounted || source == null) {
      setState(() => _picking = false);
      return;
    }

    try {
      // Uses FileType.custom + withData:true — avoids Android crash
      // that FileType.image triggers via compressImage() on Android 10+
      final file = await pickImageToCache();
      if (!mounted) return;
      if (file != null) setState(() => _pickedImage = file);
    } catch (_) {
      // picker cancelled or permission denied — ignore
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _shopNameCtrl, _ownerNameCtrl, _phoneCtrl, _emailCtrl, _cityCtrl
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
        Text('Profile updated!', style: GoogleFonts.inter(fontSize: 13)),
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
          const ProfileSubHeader(title: 'Edit Profile'),
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    // Tappable avatar
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Avatar: picked image or initials
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: accentOrange,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: _pickedImage != null
                                      ? accentOrange
                                      : Colors.transparent,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text('AS',
                                        style: GoogleFonts.inter(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white)),
                                  ),
                          ),
                          // Camera badge
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _picking ? textMuted : primaryNavy,
                                shape: BoxShape.circle,
                                border: Border.all(color: bgColor, width: 2),
                              ),
                              child: _picking
                                  ? const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.camera_alt_rounded,
                                      size: 15, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _pickedImage != null
                          ? 'Photo selected — tap to change'
                          : 'Tap to add profile photo',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _pickedImage != null
                              ? successText
                              : textMuted),
                    ),
                    const SizedBox(height: 28),

                    ProfileFormCard(children: [
                      ProfileField(
                        ctrl: _shopNameCtrl,
                        label: 'Shop Name',
                        icon: Icons.storefront_rounded,
                        hint: 'Your shop name',
                        validator: requiredValidator,
                      ),
                      ProfileField(
                        ctrl: _ownerNameCtrl,
                        label: 'Owner Name',
                        icon: Icons.person_outline_rounded,
                        hint: 'Your full name',
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
                        readOnly: true,
                        validator: emailValidator,
                      ),
                      ProfileField(
                        ctrl: _cityCtrl,
                        label: 'City',
                        icon: Icons.location_on_outlined,
                        hint: 'City, Country',
                        last: true,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          ProfileSaveBar(saving: _saving, onSave: _save),
    );
  }
}

// ── Image source enum & bottom sheet ─────────────────────────────────────────
enum _ImageSource { gallery, camera }

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text('Change Profile Photo',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SourceTile(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: infoText,
                    bg: infoBg,
                    onTap: () =>
                        Navigator.pop(context, _ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SourceTile(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: const Color(0xFF6C5CE7),
                    bg: const Color(0xFFF0EEFF),
                    onTap: () =>
                        Navigator.pop(context, _ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
