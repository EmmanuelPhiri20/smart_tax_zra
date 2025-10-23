import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  final List<String> _tabs = ["Home", "Payments", "History", "Profile", "Settings"];
  List<String> get tabs => _tabs;

  DashboardController() {


    _currentUser = _auth.currentUser;
    _auth.userChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void onTabSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
