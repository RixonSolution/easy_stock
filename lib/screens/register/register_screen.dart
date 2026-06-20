import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';
import '../../providers/registration_provider.dart';
import 'steps/step_0_details.dart';
import 'steps/step_1_photo.dart';
import 'steps/step_2_documents.dart';
import 'steps/step_3_review.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const _stepLabels = [
    'Details',
    'Photo',
    'Documents',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(),
      child: const _RegisterBody(),
    );
  }
}

class _RegisterBody extends StatelessWidget {
  const _RegisterBody();

  @override
  Widget build(BuildContext context) {
    final reg = context.watch<RegistrationProvider>();
    final step = reg.currentStep;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: textPrimary),
                onPressed: () => context.read<RegistrationProvider>().prevStep(),
              )
            : null,
        title: Text(
          RegisterScreen._stepLabels[step],
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: Column(
        children: [
          // Progress bar — 4 flex segments, orange fills up to currentStep
          _ProgressBar(currentStep: step, totalSteps: 4),

          // Step content
          Expanded(
            child: IndexedStack(
              index: step,
              children: [
                Step0Details(
                  onNext: () =>
                      context.read<RegistrationProvider>().nextStep(),
                ),
                Step1Photo(
                  onNext: () =>
                      context.read<RegistrationProvider>().nextStep(),
                ),
                Step2Documents(
                  onNext: () =>
                      context.read<RegistrationProvider>().nextStep(),
                ),
                Step3Review(
                  onSubmit: () async {
                    final ref =
                        await context.read<RegistrationProvider>().submit();
                    if (context.mounted) {
                      context.go('/register/pending', extra: ref);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceWhite,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) return const SizedBox(width: 6);
          final segIndex = i ~/ 2;
          final filled = segIndex <= currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: filled ? accentOrange : borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
