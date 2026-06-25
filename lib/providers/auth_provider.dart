import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum VerificationStatus { none, pending, approved, rejected }
enum SubscriptionStatus { none, active, expiring, expired }

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? _user;
  VerificationStatus _verificationStatus = VerificationStatus.none;
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.none;
  bool _ready = false;

  String _shopName         = '';
  String _ownerName        = '';
  String _phone            = '';
  String _email            = '';
  String _city             = '';
  String _address          = '';
  String _referenceNumber  = '';
  String _subscriptionPlan = '';

  bool get isLoggedIn        => _user != null;
  String get uid             => _user?.uid ?? '';
  VerificationStatus get verificationStatus => _verificationStatus;
  SubscriptionStatus get subscriptionStatus => _subscriptionStatus;
  String get referenceNumber => _referenceNumber;
  bool get isReady           => _ready;
  String get shopName         => _shopName;
  String get ownerName        => _ownerName;
  String get city             => _city;
  String get address          => _address;
  String get email            => _email;
  String get phone            => _phone;
  String get subscriptionPlan => _subscriptionPlan;

  String get initials {
    if (_ownerName.isEmpty) return 'R';
    final parts = _ownerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _ownerName[0].toUpperCase();
  }

  bool get canAccess =>
      _verificationStatus == VerificationStatus.approved &&
      _subscriptionStatus == SubscriptionStatus.active;

  bool get isPending => _verificationStatus == VerificationStatus.pending;

  bool get isApprovedNoSub =>
      _verificationStatus == VerificationStatus.approved &&
      _subscriptionStatus != SubscriptionStatus.active;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _clearProfile();
      _ready = true;
      notifyListeners();
    } else {
      _email = user.email ?? '';
      await _fetchUserData(user.uid);
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _db.collection('retailers').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        _shopName         = d['shopName']         as String? ?? '';
        _ownerName        = d['ownerName']        as String? ?? '';
        _phone            = d['phone']            as String? ?? '';
        _email            = d['email']            as String? ?? _user?.email ?? '';
        _city             = d['city']             as String? ?? '';
        _address          = d['address']          as String? ?? '';
        _referenceNumber  = d['referenceNumber']  as String? ?? '';
        _subscriptionPlan = d['subscriptionPlan'] as String? ?? '';
        _verificationStatus = _parseVS(d['verificationStatus'] as String?);
        _subscriptionStatus = _parseSS(d['subscriptionStatus'] as String?);
      } else {
        // Firestore doc not yet created (registration in progress)
        _verificationStatus = VerificationStatus.pending;
        _subscriptionStatus = SubscriptionStatus.none;
      }
    } catch (_) {
      _verificationStatus = VerificationStatus.none;
      _subscriptionStatus = SubscriptionStatus.none;
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _fetchUserData(uid);
  }

  Future<void> updateShopDetails({
    required String shopName,
    required String phone,
    required String address,
    required String city,
  }) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _db.collection('retailers').doc(uid).update({
      'shopName': shopName,
      'phone':    phone,
      'address':  address,
      'city':     city,
    });
    _shopName = shopName;
    _phone    = phone;
    _address  = address;
    _city     = city;
    notifyListeners();
  }

  Future<void> updatePersonalInfo({
    required String ownerName,
    required String phone,
  }) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _db.collection('retailers').doc(uid).update({
      'ownerName': ownerName,
      'phone':     phone,
    });
    _ownerName = ownerName;
    _phone     = phone;
    notifyListeners();
  }

  // Writes subscriptionStatus:active to Firestore then refreshes local state.
  // Call this after the retailer confirms manual payment (EasyPaisa/JazzCash).
  // Replace the body with a backend webhook call once payment gateway is live.
  Future<void> activateSubscription(String planId) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _db.collection('retailers').doc(uid).update({
      'subscriptionStatus': 'active',
      'subscriptionPlan':   planId,
      'subscriptionStart':  FieldValue.serverTimestamp(),
    });
    await refreshProfile();
  }

  void _clearProfile() {
    _shopName = _ownerName = _phone = _email = _city = _address =
        _referenceNumber = _subscriptionPlan = '';
    _verificationStatus = VerificationStatus.none;
    _subscriptionStatus = SubscriptionStatus.none;
  }

  // Returns null on success, an error message string on failure.
  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await _fetchUserData(cred.user!.uid);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Returns null on success, an error message string on failure.
  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Returns null on success, error message on failure.
  // Re-authenticates first (Firebase requires it before password changes).
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _user;
    if (user == null || user.email == null) return 'Not logged in.';
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  VerificationStatus _parseVS(String? s) {
    switch (s) {
      case 'approved': return VerificationStatus.approved;
      case 'rejected': return VerificationStatus.rejected;
      case 'pending':  return VerificationStatus.pending;
      default:         return VerificationStatus.none;
    }
  }

  SubscriptionStatus _parseSS(String? s) {
    switch (s) {
      case 'active':   return SubscriptionStatus.active;
      case 'expiring': return SubscriptionStatus.expiring;
      case 'expired':  return SubscriptionStatus.expired;
      default:         return SubscriptionStatus.none;
    }
  }
}
