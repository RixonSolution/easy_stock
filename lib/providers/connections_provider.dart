import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ConnectionsProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _sub;

  // wholesalerId → status string
  Map<String, String> _statusMap = {};
  // wholesalerId → connectionId
  Map<String, String> _idMap = {};
  // wholesalerId → full connection doc data (snapshot fields)
  Map<String, Map<String, dynamic>> _connectionData = {};

  bool _loading = true;

  bool get loading => _loading;
  Map<String, String> get statusMap => _statusMap;

  String statusFor(String wholesalerId) => _statusMap[wholesalerId] ?? 'none';
  String? connectionId(String wholesalerId) => _idMap[wholesalerId];

  int get approvedCount =>
      _statusMap.values.where((s) => s == 'approved').length;

  List<Map<String, dynamic>> get approvedConnections => _connectionData.values
      .where((d) => (d['status'] as String? ?? '') == 'approved')
      .toList();

  // Call once after login — streams all connections for this retailer
  void listen(String retailerId) {
    _sub?.cancel();
    _loading = true;
    _sub = _db
        .collection('connections')
        .where('retailerId', isEqualTo: retailerId)
        .snapshots()
        .listen(
      (snap) {
        _statusMap      = {};
        _idMap          = {};
        _connectionData = {};
        for (final doc in snap.docs) {
          final d    = doc.data() as Map<String, dynamic>? ?? {};
          final wId  = d['wholesalerId'] as String? ?? '';
          final stat = d['status']       as String? ?? 'pending';
          if (wId.isNotEmpty) {
            _statusMap[wId]      = stat;
            _idMap[wId]          = doc.id;
            _connectionData[wId] = d;
          }
        }
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        notifyListeners();
      },
    );
  }

  // Send a new connection request — checks for duplicate first
  Future<void> sendRequest({
    required String retailerId,
    required String retailerName,
    required String retailerCity,
    required String wholesalerId,
    required String wholesalerName,
    required String wholesalerCity,
    required String wholesalerBrands,
    required String wholesalerPhone,
    required String wholesalerAddress,
    required String wholesalerEmail,
    required int    wholesalerColorIndex,
  }) async {
    // Prevent duplicate requests
    if (_statusMap.containsKey(wholesalerId)) return;

    // Optimistic update so UI responds instantly
    _statusMap[wholesalerId] = 'pending';
    notifyListeners();

    try {
      final ref = await _db.collection('connections').add({
        'retailerId':           retailerId,
        'wholesalerId':         wholesalerId,
        'status':               'pending',
        'requestedAt':          FieldValue.serverTimestamp(),
        'respondedAt':          null,
        'retailerName':         retailerName,
        'retailerCity':         retailerCity,
        'wholesalerName':       wholesalerName,
        'wholesalerCity':       wholesalerCity,
        'wholesalerBrands':     wholesalerBrands,
        'wholesalerPhone':      wholesalerPhone,
        'wholesalerAddress':    wholesalerAddress,
        'wholesalerEmail':      wholesalerEmail,
        'wholesalerColorIndex': wholesalerColorIndex,
        'rejectionReason':      '',
      });
      _idMap[wholesalerId] = ref.id;
      notifyListeners();
    } catch (e) {
      debugPrint('ConnectionsProvider.sendRequest error: $e');
      // Rollback optimistic update on failure
      _statusMap.remove(wholesalerId);
      _idMap.remove(wholesalerId);
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _sub?.cancel();
    _sub = null;
    _statusMap      = {};
    _idMap          = {};
    _connectionData = {};
    _loading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
