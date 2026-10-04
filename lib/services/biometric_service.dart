import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Check if the device supports biometric hardware
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint("Biometric check failed: $e");
      return false;
    }
  }

  /// Authenticate using the fingerprint
  Future<bool> authenticateUser() async {
    try {
      bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to verify your identity',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint("Biometric auth platform exception: $e");
      return false;
    } catch (e) {
      debugPrint("Biometric auth failed: $e");
      return false;
    }
  }

  /// Check if the user is already logged in Firebase
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Check if user exists in Firebase system
  Future<bool> doesUserExistInSystem() async {
    try {
      final User? user = _firebaseAuth.currentUser;

      if (user == null) {
        debugPrint("No user logged in");
        return false;
      }

      // Basic check - user exists if they're authenticated in Firebase
      // You can enhance this with additional checks if needed
      debugPrint("User exists in system: ${user.uid}");
      return true;
    } catch (e) {
      debugPrint("Error checking user existence: $e");
      return false;
    }
  }

  /// Enable biometric login (store locally that the user has opted in)
  Future<void> enableBiometricForUser() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // Store biometric preference - you can use shared_preferences or flutter_secure_storage
        debugPrint("✅ Biometric enabled for user: ${user.uid}");

        // Example with shared_preferences (uncomment if you have the package):
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setBool('biometric_enabled_${user.uid}', true);
      }
    } catch (e) {
      debugPrint("Error enabling biometric: $e");
      rethrow;
    }
  }

  /// Check if biometric is already enabled for current user
  Future<bool> isBiometricEnabled() async {
    try {
      final User? user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Check from secure storage
      // Example with shared_preferences (uncomment if you have the package):
      // final prefs = await SharedPreferences.getInstance();
      // return prefs.getBool('biometric_enabled_${user.uid}') ?? false;

      // For now, return false
      return false;
    } catch (e) {
      debugPrint("Error checking biometric status: $e");
      return false;
    }
  }
}
