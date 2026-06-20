import 'dart:io';
import 'package:flutter/foundation.dart';

class RegistrationProvider extends ChangeNotifier {
  // ── Step 0 fields ─────────────────────────────────────────────────────────
  String shopName  = '';
  String ownerName = '';
  String phone     = '';
  String email     = '';
  String city      = '';

  // ── Staged files (local — uploaded at final submit) ───────────────────────
  File? shopPhoto;
  File? businessCard;
  File? cnicFront;

  // ── Flow state ────────────────────────────────────────────────────────────
  int  currentStep    = 0;
  bool isSubmitting   = false;
  String? referenceNumber;

  // ── Validation helpers ────────────────────────────────────────────────────
  bool get step0Valid =>
      shopName.trim().isNotEmpty &&
      ownerName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      city.trim().isNotEmpty;

  bool get allDocsStaged =>
      shopPhoto != null && businessCard != null && cnicFront != null;

  // ── Field update (avoids a setter per field) ──────────────────────────────
  void setField(String key, String value) {
    switch (key) {
      case 'shopName':  shopName  = value;
      case 'ownerName': ownerName = value;
      case 'phone':     phone     = value;
      case 'email':     email     = value;
      case 'city':      city      = value;
    }
    notifyListeners();
  }

  void setFile(String key, File? file) {
    switch (key) {
      case 'shopPhoto':     shopPhoto    = file;
      case 'businessCard':  businessCard = file;
      case 'cnicFront':     cnicFront    = file;
    }
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  // ── Submit — uploads files then writes Firestore doc ──────────────────────
  // TODO: replace simulation with real Firebase calls once firebase_options.dart
  // is wired (run flutterfire configure).
  Future<String> submit() async {
    isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200)); // simulate upload

    final ref = 'SK-${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}';
    referenceNumber = ref;
    isSubmitting = false;
    notifyListeners();
    return ref;
  }

  void reset() {
    shopName = ownerName = phone = email = city = '';
    shopPhoto = businessCard = cnicFront = null;
    currentStep = 0;
    isSubmitting = false;
    referenceNumber = null;
    notifyListeners();
  }
}
