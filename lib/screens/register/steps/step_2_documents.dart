import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme.dart';
import '../../../providers/registration_provider.dart';
import '../../../utils/image_picker_helper.dart';
import '../../../widgets/upload_tile.dart';

class Step2Documents extends StatefulWidget {
  const Step2Documents({super.key, required this.onNext});
  final VoidCallback onNext;

  @override
  State<Step2Documents> createState() => _Step2DocumentsState();
}

class _Step2DocumentsState extends State<Step2Documents> {
  bool _pickingCard = false;
  bool _pickingCnic = false;

  Future<void> _pick(String key) async {
    final isCard = key == 'businessCard';
    if (isCard ? _pickingCard : _pickingCnic) return;

    setState(() {
      if (isCard) { _pickingCard = true; } else { _pickingCnic = true; }
    });

    try {
      final file = await pickImageToCache();
      if (file != null && mounted) {
        context.read<RegistrationProvider>().setFile(key, file);
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isCard) { _pickingCard = false; } else { _pickingCnic = false; }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegistrationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload your business documents for verification.',
            style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
          ),
          const SizedBox(height: 28),

          _PickerTile(
            label: 'Business Card',
            sub: reg.businessCard != null
                ? 'Document staged — will upload on submit'
                : 'JPG or PNG, clear and readable',
            done: reg.businessCard != null,
            loading: _pickingCard,
            onTap: () => _pick('businessCard'),
          ),
          const SizedBox(height: 14),
          _PickerTile(
            label: 'CNIC Front',
            sub: reg.cnicFront != null
                ? 'Document staged — will upload on submit'
                : 'National ID card, front side only',
            done: reg.cnicFront != null,
            loading: _pickingCnic,
            onTap: () => _pick('cnicFront'),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: infoBg,
              borderRadius: BorderRadius.circular(pillRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: infoText, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Files are uploaded securely when you submit your application.',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: infoText, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (reg.businessCard != null && reg.cnicFront != null)
                ? widget.onNext
                : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: borderColor,
              disabledForegroundColor: textMuted,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Wraps UploadTile with a loading overlay for when the picker is open.
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.sub,
    required this.done,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final String sub;
  final bool done;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UploadTile(label: label, sub: sub, done: done, onTap: onTap),
        if (loading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: accentOrange, strokeWidth: 2.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
