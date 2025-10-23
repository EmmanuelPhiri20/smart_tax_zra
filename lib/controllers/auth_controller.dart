import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/constants/route_names.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  // ========================= SIGN UP =========================
  Future<void> signUp(
      String email,
      String password,
      String name,
      String phone,
      BuildContext context,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.signUpWithEmail(email, password);

      if (user != null) {
        currentUser = UserModel.fromFirebaseUser(user);
        print("✅ Sign-up successful for: ${user.email}");

        // Redirect to Dashboard after successful signup
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      }
    } catch (e) {
      errorMessage = e.toString();
      print("❌ Sign-up failed: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up failed: $errorMessage")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================= SIGN IN =========================
  Future<void> signIn(
      String email,
      String password,
      BuildContext context,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithEmail(email, password);

      if (user != null) {
        currentUser = UserModel.fromFirebaseUser(user);
        print("✅ Login successful for: ${user.email}");

        // Redirect to Dashboard after successful login
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      }
    } catch (e) {
      errorMessage = e.toString();
      print("❌ Login failed: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $errorMessage")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================= GOOGLE SIGN-IN =========================
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        currentUser = UserModel.fromFirebaseUser(user);
        print("✅ Google Sign-in successful for: ${user.email}");

        // Redirect to Dashboard after successful login
        Navigator.pushReplacementNamed(context, RouteNames.dashboard);
      }
    } catch (e) {
      errorMessage = e.toString();
      print("❌ Google sign-in failed: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google sign-in failed: $errorMessage")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================= SIGN OUT =========================
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    currentUser = null;
    notifyListeners();

    // Redirect to Login screen after sign-out
    Navigator.pushReplacementNamed(context, RouteNames.login);
  }

  // ========================= RESET PASSWORD =========================
  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }
}
