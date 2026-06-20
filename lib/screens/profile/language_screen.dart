import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/theme.dart';
import 'profile_widgets.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'en';

  static const _languages = [
    _Lang('en', 'English', 'English', '🇬🇧'),
    _Lang('ur', 'اردو', 'Urdu', '🇵🇰'),
    _Lang('pa', 'پنجابی', 'Punjabi', '🇵🇰'),
  ];

  void _apply() {
    final lang = _languages.firstWhere((l) => l.code == _selected);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text('Language changed to ${lang.name}',
            style: GoogleFonts.inter(fontSize: 13)),
      ]),
      backgroundColor: successText,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius)),
      duration: const Duration(seconds: 2),
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const ProfileSubHeader(title: 'Language'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select your preferred language',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: List.generate(_languages.length, (i) {
                        final lang = _languages[i];
                        final isSelected = lang.code == _selected;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => _selected = lang.code),
                              borderRadius: BorderRadius.vertical(
                                top: i == 0
                                    ? const Radius.circular(cardRadius)
                                    : Radius.zero,
                                bottom: i == _languages.length - 1
                                    ? const Radius.circular(cardRadius)
                                    : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(children: [
                                  Text(lang.flag,
                                      style:
                                          const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(lang.native,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? primaryNavy
                                                  : textPrimary,
                                            )),
                                        Text(lang.name,
                                            style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: textSecondary)),
                                      ],
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryNavy
                                            : borderColor,
                                        width: isSelected ? 6 : 1.5,
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                            if (i < _languages.length - 1)
                              const Divider(
                                  height: 1,
                                  indent: 64,
                                  color: borderColor),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: const BoxDecoration(
          color: surfaceWhite,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: ElevatedButton(
          onPressed: _apply,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52)),
          child: Text('Apply Language',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Lang {
  const _Lang(this.code, this.native, this.name, this.flag);
  final String code, native, name, flag;
}
