import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../providers/registration_provider.dart';
import '../../../utils/image_picker_helper.dart';

class Step1Photo extends StatefulWidget {
  const Step1Photo({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<Step1Photo> createState() => _Step1PhotoState();
}

class _Step1PhotoState extends State<Step1Photo> {
  bool _picking = false;

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await pickImageToCache();
      if (file != null && mounted) {
        context.read<RegistrationProvider>().setFile('shopPhoto', file);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegistrationProvider>();
    final photo = reg.shopPhoto;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Photo',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a photo of your shop front so distributors recognise you.',
            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 28),

          // Preview / picker tile
          GestureDetector(
            onTap: _picking ? null : _pick,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(
                  color: photo != null ? accentOrange : borderColor,
                  width: photo != null ? 2 : 1,
                ),
                image: photo != null
                    ? DecorationImage(
                        image: FileImage(photo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _picking
                  ? const Center(
                      child: CircularProgressIndicator(color: accentOrange),
                    )
                  : photo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: surfaceWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: const Icon(
                                Icons.add_a_photo_outlined,
                                color: textSecondary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to select shop photo',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG or PNG from your gallery',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textMuted),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () => context
                                  .read<RegistrationProvider>()
                                  .setFile('shopPhoto', null),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
            ),
          ),

          if (photo != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pick,
              child: Text(
                'Change photo',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accentOrange,
                  decoration: TextDecoration.underline,
                  decorationColor: accentOrange,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: photo != null ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: borderColor,
              disabledForegroundColor: textMuted,
            ),
            child: const Text('Continue'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onNext,
              child: Text(
                'Skip for now',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
