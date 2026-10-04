import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/constants/route_names.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;
  String? verificationId;

  // ========================= SIGN UP =========================
  Future<void> signUp(
    String name,
    String phone,
    String tpin,
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      // ✅ Match the actual parameters of verifyPhoneNumber
      await _authService.verifyPhoneNumber(
        phone,
        context,
        (id) {
          verificationId = id;

          // ⚡ Navigate to OTP screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, RouteNames.otp, arguments: {
              'verificationId': id,
              'isFromSignUp': true,
            });
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-up failed: $e")),
      );
    } finally {
      // Add a short delay to ensure the loader remains visible
      await Future.delayed(const Duration(seconds: 2));
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================= LOGIN =========================
  Future<void> signIn(
    String phone,
    String password,
    BuildContext context,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phone,
        context,
        (id) {
          verificationId = id;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(context, RouteNames.otp, arguments: {
              'verificationId': id,
              'isFromSignUp': false,
            });
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ========================= VERIFY OTP =========================
  Future<void> verifyOtpCode(String smsCode, BuildContext context) async {
    if (verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification ID missing.")),
      );
      return;
    }

    try {
      final user = await _authService.verifyOTP(smsCode);

      if (user != null) {
        currentUser = UserModel.fromFirebaseUser(user);

        // ✅ Navigate to dashboard after verification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.dashboard,
            (route) => false,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or expired OTP.")),
      );
    }
  }

  // ========================= SIGN OUT =========================
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    currentUser = null;
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    });
  }
}
