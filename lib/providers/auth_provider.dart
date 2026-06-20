import 'package:flutter/foundation.dart';

enum VerificationStatus { none, pending, approved, rejected }
enum SubscriptionStatus { none, active, expiring, expired }

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  VerificationStatus _verificationStatus = VerificationStatus.none;
  SubscriptionStatus _subscriptionStatus = SubscriptionStatus.none;
  String _referenceNumber = '';

  bool get isLoggedIn => _isLoggedIn;
  VerificationStatus get verificationStatus => _verificationStatus;
  SubscriptionStatus get subscriptionStatus => _subscriptionStatus;
  String get referenceNumber => _referenceNumber;

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

  void setRegistered(String referenceNumber) {
    _isLoggedIn = true;
    _verificationStatus = VerificationStatus.pending;
    _referenceNumber = referenceNumber;
    notifyListeners();
  }

  // Demo helper — call this to simulate admin approving the shop
  void simulateAdminApproval() {
    _verificationStatus = VerificationStatus.approved;
    notifyListeners();
  }

  // Demo helper — call this to simulate admin confirming subscription payment
  void simulateSubscriptionActivated() {
    _subscriptionStatus = SubscriptionStatus.active;
    notifyListeners();
  }
}
