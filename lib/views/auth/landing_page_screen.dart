import 'package:flutter/material.dart';
import '../../core/constants/route_names.dart';
import '../../core/theme/colors.dart';

class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wp13202115-elephant-phone-wallpapers 1.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.35)),

          // Page content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔹 ZRA logo at top-right
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Image.asset(
                        'assets/icons/zra.png',
                        height: 53,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 🏛️ ZRA title
                  const Text(
                    "Zambia Revenue\nAuthority",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login or sign-up to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 17),
                  ),
                  const SizedBox(height: 40),

                  // 🟩 Register Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.signup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Register"),
                  ),
                  const SizedBox(height: 15),

                  // 🟦 Login Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔒 Biometric Icon (clickable)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RouteNames.biometric);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.fingerprint,
                            color: Colors.white, size: 70),
                        SizedBox(height: 10),
                        Text(
                          "Use biometrics",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const Text(
                    "Help?\nTerms of Use",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
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
