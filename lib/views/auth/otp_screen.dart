import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/colors.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final bool isFromSignUp;

  const OtpScreen({
    super.key,
    required this.verificationId,
    this.isFromSignUp = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _seconds = 120;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _seconds = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 🐘 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wp13202115-elephant-phone-wallpapers 1.png',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay for better text contrast
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔹 ZRA Logo Top-Right
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/icons/zra.png',
                      height: 53,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🧾 Title
                  const Text(
                    "Phone Verification",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the 6-digit code sent to your phone",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // 🔢 OTP Input Field
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: "••••••",
                      hintStyle:
                          const TextStyle(color: Colors.white54, fontSize: 28),
                      filled: true,
                      fillColor: const Color(0xFF2A61F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⏳ Countdown Timer
                  Text(
                    _canResend
                        ? "Didn’t get the code?"
                        : "Resend available in ${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

                  // 🔁 Resend OTP Button
                  ElevatedButton(
                    onPressed: _canResend
                        ? () async {
                            setState(() => _canResend = false);
                            _startTimer();

                            // Re-send OTP
                            await authController.signIn(
                              authController.currentUser?.phone ?? '',
                              '', // password not required for OTP resend
                              context,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _canResend ? AppColors.primary : Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        fontSize: 15,
                        color: _canResend ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ✅ Verify OTP Button
                  authController.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_otpController.text.length == 6) {
                              await authController.verifyOtpCode(
                                _otpController.text.trim(),
                                context,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Enter the full 6-digit OTP code."),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            "Verify Code",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
