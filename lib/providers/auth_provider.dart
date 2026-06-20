import 'package:flutter/foundation.dart';

enum VerificationStatus { none, pending, approved, rejected }
enum SubscriptionStatus { none, active, expiring, expired }

class AuthProvider extends ChangeNotifier {
  bool get isLoggedIn => false; // TODO: wire Firebase Auth
  VerificationStatus get verificationStatus => VerificationStatus.none;
  SubscriptionStatus get subscriptionStatus => SubscriptionStatus.none;

  String get shopName => '';
  String get ownerName => '';
  String get city => '';
  String get initials => '';
}
