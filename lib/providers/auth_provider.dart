import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VerificationStatus { none, pending, approved, rejected }
enum SubscriptionStatus { none, active, expiring, expired }

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  VerificationStatus _verificationStatus = VerificationStatus.none;
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.none;
  String _referenceNumber = '';
  bool _ready = false;

  bool get isLoggedIn => _isLoggedIn;
  VerificationStatus get verificationStatus => _verificationStatus;
  SubscriptionStatus get subscriptionStatus => _subscriptionStatus;
  String get referenceNumber => _referenceNumber;
  bool get isReady => _ready;

  bool get canAccess =>
      _verificationStatus == VerificationStatus.approved &&
      _subscriptionStatus == SubscriptionStatus.active;

  bool get isPending => _verificationStatus == VerificationStatus.pending;

  bool get isApprovedNoSub =>
      _verificationStatus == VerificationStatus.approved &&
      _subscriptionStatus != SubscriptionStatus.active;

  String get shopName => '';
  String get ownerName => '';
  String get city => '';
  String get initials => '';

  AuthProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('auth_isLoggedIn') ?? false;
    _verificationStatus = VerificationStatus
        .values[prefs.getInt('auth_verificationStatus') ?? 0];
    _subscriptionStatus = SubscriptionStatus
        .values[prefs.getInt('auth_subscriptionStatus') ?? 0];
    _referenceNumber = prefs.getString('auth_referenceNumber') ?? '';
    _ready = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_isLoggedIn', _isLoggedIn);
    await prefs.setInt('auth_verificationStatus', _verificationStatus.index);
    await prefs.setInt('auth_subscriptionStatus', _subscriptionStatus.index);
    await prefs.setString('auth_referenceNumber', _referenceNumber);
  }

  void setRegistered(String referenceNumber) {
    _isLoggedIn = true;
    _verificationStatus = VerificationStatus.pending;
    _referenceNumber = referenceNumber;
    notifyListeners();
    _saveToPrefs();
  }

  // Demo helper — call this to simulate admin approving the shop
  void simulateAdminApproval() {
    _verificationStatus = VerificationStatus.approved;
    notifyListeners();
    _saveToPrefs();
  }

  // Demo helper — call this to simulate admin confirming subscription payment
  void simulateSubscriptionActivated() {
    _subscriptionStatus = SubscriptionStatus.active;
    notifyListeners();
    _saveToPrefs();
  }
}
