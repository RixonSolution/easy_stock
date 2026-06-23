import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RegistrationProvider extends ChangeNotifier {
  // Step 0 fields
  String shopName  = '';
  String ownerName = '';
  String phone     = '';
  String email     = '';
  String password  = '';
  String address   = '';
  String city      = '';

  // Staged files (uploaded at final submit)
  File? shopPhoto;
  File? businessCard;
  File? cnicFront;

  // Flow state
  int     currentStep    = 0;
  bool    isSubmitting   = false;
  String? referenceNumber;

  bool get step0Valid =>
      shopName.trim().isNotEmpty &&
      ownerName.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty;

  bool get allDocsStaged =>
      shopPhoto != null && businessCard != null && cnicFront != null;

  void setField(String key, String value) {
    switch (key) {
      case 'shopName':  shopName  = value;
      case 'ownerName': ownerName = value;
      case 'phone':     phone     = value;
      case 'email':     email     = value;
      case 'password':  password  = value;
      case 'address':   address   = value;
      case 'city':      city      = value;
    }
    notifyListeners();
  }

  void setFile(String key, File? file) {
    switch (key) {
      case 'shopPhoto':    shopPhoto    = file;
      case 'businessCard': businessCard = file;
      case 'cnicFront':    cnicFront    = file;
    }
    notifyListeners();
  }

  void nextStep() {
    if (currentStep < 3) { currentStep++; notifyListeners(); }
  }

  void prevStep() {
    if (currentStep > 0) { currentStep--; notifyListeners(); }
  }

  // Creates Firebase Auth user, uploads files, writes Firestore doc.
  // Throws a descriptive String on failure.
  Future<String> submit() async {
    isSubmitting = true;
    notifyListeners();

    try {
      // 1. Create Firebase Auth account
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;

      // TODO: upload shop photo, business card, cnic front to Firebase Storage
      // once billing is upgraded. For now URLs are stored as empty strings.
      const shopPhotoUrl    = '';
      const businessCardUrl = '';
      const cnicFrontUrl    = '';

      // 2. Generate reference number
      final refNum =
          'SK-${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}';

      // 3. Write retailer doc to Firestore
      await FirebaseFirestore.instance.collection('retailers').doc(uid).set({
        'shopName':        shopName.trim(),
        'ownerName':       ownerName.trim(),
        'phone':           phone.trim(),
        'email':           email.trim(),
        'address':         address.trim(),
        'city':            city.trim(),
        'shopPhotoUrl':    shopPhotoUrl,
        'businessCardUrl': businessCardUrl,
        'cnicFrontUrl':    cnicFrontUrl,
        'verificationStatus': 'pending',
        'subscriptionStatus': 'none',
        'referenceNumber': refNum,
        'role':            'retailer',
        'createdAt':       FieldValue.serverTimestamp(),
      });

      referenceNumber = refNum;
      isSubmitting = false;
      notifyListeners();
      return refNum;
    } on FirebaseAuthException catch (e) {
      isSubmitting = false;
      notifyListeners();
      throw Exception(_authErrorMessage(e.code));
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      if (e is Exception) rethrow;
      throw Exception('Registration failed. Please try again.');
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Please sign in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  void reset() {
    shopName = ownerName = phone = email = password = address = city = '';
    shopPhoto = businessCard = cnicFront = null;
    currentStep = 0;
    isSubmitting = false;
    referenceNumber = null;
    notifyListeners();
  }
}
