import 'package:flutter/material.dart';
import '../../core/constants/route_names.dart';
import '../../core/theme/colors.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onScan() async {
    setState(() {
      _isScanning = true;
    });
    _animationController.forward();

    // TODO: Connect this part later with your biometric_service.dart
    await Future.delayed(const Duration(seconds: 3));

    _animationController.stop();
    setState(() {
      _isScanning = false;
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🐘 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wp13202115-elephant-phone-wallpapers 1.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.45)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ZRA Logo top-right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Image.asset(
                        'assets/icons/zra.png',
                        height: 53,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "Enable Biometric Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Use your fingerprint for secure and fast access.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 40),

                  // 🔹 Animated Fingerprint
                  GestureDetector(
                    onTap: _onScan,
                    child: ScaleTransition(
                      scale: _animationController,
                      child: Icon(
                        Icons.fingerprint,
                        color: _isScanning
                            ? Colors.lightBlueAccent
                            : Colors.white,
                        size: 100,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _onScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Enable Biometric Login",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, RouteNames.dashboard);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Skip for now",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    "Your fingerprint data is securely stored\nand never shared with ZRA.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
