import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // ✅ Dashboard Tabs
  final List<String> _tabs = ["Home", "Chat", "Filing", "History", "Settings"];
  List<String> get tabs => _tabs;

  // ✅ Analytics fields
  int anomalies = 0;
  int normal = 0;
  int total = 0;

  DashboardController() {
    _currentUser = _auth.currentUser;
    _auth.userChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUserData(); // 🔥 load analytics when user logs in
      }
      notifyListeners();
    });
  }

  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // ✅ Called from FilingScreen to update analytics + persist in Firestore
  Future<void> updateAnalytics({
    required int anomalyCount,
    required int normalCount,
  }) async {
    anomalies = anomalyCount;
    normal = normalCount;
    total = anomalyCount + normalCount;
    notifyListeners();

    final phone = _currentUser?.phoneNumber;
    if (phone != null) {
      await _firestore.collection('users').doc(phone).set({
        'analytics': {
          'anomalies': anomalies,
          'normal': normal,
          'total': total,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    }
  }

  // ✅ Load saved analytics when user logs in
  Future<void> _loadUserData() async {
    final phone = _currentUser?.phoneNumber;
    if (phone == null) return;

    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      final data = doc.data();
      if (data != null && data['analytics'] != null) {
        anomalies = data['analytics']['anomalies'] ?? 0;
        normal = data['analytics']['normal'] ?? 0;
        total = data['analytics']['total'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ Error loading user analytics: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
