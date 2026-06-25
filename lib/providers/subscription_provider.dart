import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SubLifecycle {
  unknown,
  pendingApproval,
  trial,
  active,
  expiring,
  grace,
  paymentRequired,
  expired,
  suspended,
}

class PlanInfo {
  const PlanInfo({
    required this.key,
    required this.label,
    required this.shortLabel,
    required this.billingMonths,
    required this.price,
    required this.features,
  });
  final String key, label, shortLabel;
  final int billingMonths, price;
  final List<String> features;

  String get priceLabel => 'Rs. ${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      )}';

  String get periodLabel => billingMonths == 12 ? 'per year' : 'per month';
}

class PaymentAccount {
  const PaymentAccount({
    required this.type,
    required this.title,
    this.accountName = '',
    this.accountNumber = '',
    this.bankName = '',
    this.accountTitle = '',
    this.iban = '',
  });
  final String type, title, accountName, accountNumber;
  final String bankName, accountTitle, iban;
}

class SubscriptionProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  String _uid = '';
  String _verificationStatus = 'pending';
  bool _subDocLoaded = false;

  // Platform settings (from platform_settings/subscriptions)
  int _graceDays = 3;
  int _expiryWarningDays = 7;
  PlanInfo? _monthlyPlan;
  PlanInfo? _yearlyPlan;
  List<PaymentAccount> _paymentAccounts = [];

  // User subscription doc (from subscriptions/shopkeeper_{uid})
  SubLifecycle _lifecycle = SubLifecycle.unknown;
  bool _canAccess = false;
  int? _daysLeft;
  String _planKey = '';
  DateTime? _subscriptionEnd;
  DateTime? _trialEnd;
  bool _suspended = false;

  // Billing history
  List<Map<String, dynamic>> _payments = [];

  StreamSubscription<DocumentSnapshot>? _settingsSub;
  StreamSubscription<DocumentSnapshot>? _subDocSub;
  StreamSubscription<QuerySnapshot>? _paymentsSub;

  bool get ready => _subDocLoaded;
  bool get canAccess => _canAccess;
  SubLifecycle get lifecycle => _lifecycle;
  int? get daysLeft => _daysLeft;
  String get planKey => _planKey;
  PlanInfo? get monthlyPlan => _monthlyPlan;
  PlanInfo? get yearlyPlan => _yearlyPlan;
  List<PaymentAccount> get paymentAccounts => _paymentAccounts;
  List<Map<String, dynamic>> get payments => _payments;
  DateTime? get subscriptionEnd => _subscriptionEnd;
  DateTime? get trialEnd => _trialEnd;

  // Called by ProxyProvider on every AuthProvider change
  void update(String uid, String verificationStatus) {
    bool needsNotify = false;

    if (verificationStatus != _verificationStatus) {
      _verificationStatus = verificationStatus;
      if (uid == _uid && uid.isNotEmpty && _subDocLoaded) {
        _recompute();
        needsNotify = true;
      }
    }

    if (uid == _uid) {
      if (needsNotify) notifyListeners();
      return;
    }

    _uid = uid;
    _cancelSubs();
    _subDocLoaded = false;

    if (uid.isEmpty) {
      _reset();
      return;
    }

    _listenSettings();
    _listenSubDoc();
    _listenPayments();
  }

  void _listenSettings() {
    _settingsSub = _db
        .collection('platform_settings')
        .doc('subscriptions')
        .snapshots()
        .listen((snap) {
      final d = snap.data() ?? {};
      _graceDays = (d['graceDays'] as num?)?.toInt() ?? 3;
      _expiryWarningDays = (d['expiryWarningDays'] as num?)?.toInt() ?? 7;

      final plans = (d['plans'] as Map<String, dynamic>?) ?? {};
      _monthlyPlan = _parsePlan('shop_monthly', plans['shop_monthly']);
      _yearlyPlan = _parsePlan('shop_yearly', plans['shop_yearly']);

      final accounts = (d['paymentAccounts'] as Map<String, dynamic>?) ?? {};
      _paymentAccounts = _parseAccounts(accounts);

      if (_subDocLoaded) _recompute();
      notifyListeners();
    }, onError: (_) {
      // Use defaults if settings unavailable
      _monthlyPlan ??= _parsePlan('shop_monthly', null);
      _yearlyPlan ??= _parsePlan('shop_yearly', null);
      notifyListeners();
    });
  }

  void _listenSubDoc() {
    final docId = 'shopkeeper_$_uid';
    _subDocSub = _db
        .collection('subscriptions')
        .doc(docId)
        .snapshots()
        .listen((snap) {
      final d = snap.data() ?? {};
      _suspended = d['suspended'] == true;
      _planKey = d['planKey'] as String? ?? '';
      _subscriptionEnd = _toDate(d['subscriptionEnd']);
      _trialEnd = _toDate(d['trialEnd']);
      _subDocLoaded = true;
      _recompute();
      notifyListeners();
    }, onError: (_) {
      _subDocLoaded = true;
      _lifecycle = SubLifecycle.paymentRequired;
      _canAccess = false;
      notifyListeners();
    });
  }

  void _listenPayments() {
    _paymentsSub = _db
        .collection('subscription_payments')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snap) {
      _payments =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      notifyListeners();
    }, onError: (_) {
      // Silently ignore if index not yet deployed
    });
  }

  void _recompute() {
    if (_suspended) {
      _lifecycle = SubLifecycle.suspended;
      _canAccess = false;
      _daysLeft = null;
      return;
    }

    if (_verificationStatus != 'approved') {
      _lifecycle = SubLifecycle.pendingApproval;
      _canAccess = false;
      _daysLeft = null;
      return;
    }

    final now = DateTime.now();

    if (_subscriptionEnd != null) {
      final remaining = _subscriptionEnd!.difference(now).inDays;
      if (remaining > 0) {
        _lifecycle = remaining <= _expiryWarningDays
            ? SubLifecycle.expiring
            : SubLifecycle.active;
        _canAccess = true;
        _daysLeft = remaining;
        return;
      }
      final graceEnd = _subscriptionEnd!.add(Duration(days: _graceDays));
      final graceRemaining = graceEnd.difference(now).inDays;
      if (graceRemaining >= 0) {
        _lifecycle = SubLifecycle.grace;
        _canAccess = true;
        _daysLeft = graceRemaining;
        return;
      }
      _lifecycle = SubLifecycle.expired;
      _canAccess = false;
      _daysLeft = 0;
      return;
    }

    if (_trialEnd != null) {
      final trialRemaining = _trialEnd!.difference(now).inDays;
      if (trialRemaining >= 0) {
        _lifecycle = SubLifecycle.trial;
        _canAccess = true;
        _daysLeft = trialRemaining;
        return;
      }
    }

    _lifecycle = SubLifecycle.paymentRequired;
    _canAccess = false;
    _daysLeft = 0;
  }

  Future<void> submitPayment({
    required String planKey,
    required String txnId,
    required String method,
    required String userName,
    required String ownerName,
    required String referenceNumber,
  }) async {
    if (_uid.isEmpty) return;
    final plan = planKey == 'shop_yearly' ? _yearlyPlan : _monthlyPlan;
    final amount = plan?.price ?? 0;

    await _db.collection('subscription_payments').add({
      'subscriptionId': 'shopkeeper_$_uid',
      'userId': _uid,
      'userType': 'shopkeeper',
      'referenceNumber': referenceNumber,
      'userName': userName,
      'ownerName': ownerName,
      'planKey': planKey,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'txnId': txnId,
      'receiptUrl': '',
      'notes': 'User-submitted proof via mobile app',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  PlanInfo _parsePlan(String key, dynamic raw) {
    final d = (raw as Map<String, dynamic>?) ?? {};
    const defaults = <String, Map<String, dynamic>>{
      'shop_monthly': {
        'label': 'Retailer Monthly',
        'shortLabel': 'Monthly',
        'billingMonths': 1,
        'price': 500,
      },
      'shop_yearly': {
        'label': 'Retailer Yearly',
        'shortLabel': 'Yearly',
        'billingMonths': 12,
        'price': 5000,
      },
    };
    final def = defaults[key]!;
    return PlanInfo(
      key: key,
      label: d['label'] as String? ?? def['label'] as String,
      shortLabel: d['shortLabel'] as String? ?? def['shortLabel'] as String,
      billingMonths:
          (d['billingMonths'] as num?)?.toInt() ?? def['billingMonths'] as int,
      price: (d['price'] as num?)?.toInt() ?? def['price'] as int,
      features: (d['features'] as List<dynamic>?)?.cast<String>() ??
          [
            'Browse wholesaler stock',
            'Place and track orders',
            'Manage your own shop stock',
            'Get low-stock visibility',
          ],
    );
  }

  List<PaymentAccount> _parseAccounts(Map<String, dynamic> raw) {
    final accounts = <PaymentAccount>[];
    final ep = raw['easyPaisa'] as Map<String, dynamic>?;
    final jc = raw['jazzCash'] as Map<String, dynamic>?;
    final bk = raw['bank'] as Map<String, dynamic>?;

    if (ep != null && (ep['accountNumber'] as String? ?? '').isNotEmpty) {
      accounts.add(PaymentAccount(
        type: 'easypaisa',
        title: 'EasyPaisa',
        accountName: ep['accountName'] as String? ?? '',
        accountNumber: ep['accountNumber'] as String? ?? '',
      ));
    }
    if (jc != null && (jc['accountNumber'] as String? ?? '').isNotEmpty) {
      accounts.add(PaymentAccount(
        type: 'jazzcash',
        title: 'JazzCash',
        accountName: jc['accountName'] as String? ?? '',
        accountNumber: jc['accountNumber'] as String? ?? '',
      ));
    }
    if (bk != null && (bk['accountNumber'] as String? ?? '').isNotEmpty) {
      accounts.add(PaymentAccount(
        type: 'bank',
        title: 'Bank Transfer',
        accountName: bk['accountTitle'] as String? ?? '',
        accountNumber: bk['accountNumber'] as String? ?? '',
        bankName: bk['bankName'] as String? ?? '',
        accountTitle: bk['accountTitle'] as String? ?? '',
        iban: bk['iban'] as String? ?? '',
      ));
    }
    return accounts;
  }

  DateTime? _toDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    return null;
  }

  void _cancelSubs() {
    _settingsSub?.cancel();
    _subDocSub?.cancel();
    _paymentsSub?.cancel();
    _settingsSub = _subDocSub = null;
    _paymentsSub = null;
  }

  void _reset() {
    _lifecycle = SubLifecycle.unknown;
    _canAccess = false;
    _daysLeft = null;
    _planKey = '';
    _subscriptionEnd = null;
    _trialEnd = null;
    _suspended = false;
    _payments = [];
    _subDocLoaded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubs();
    super.dispose();
  }
}
