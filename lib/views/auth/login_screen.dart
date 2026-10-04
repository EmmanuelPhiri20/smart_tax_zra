import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/route_names.dart';
import '../../core/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '+260 ');
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    if (mounted) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricTap() async {
    // ✅ Use medium impact for better vibration
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint("Haptic feedback failed: $e");
      // Fallback to light impact
      await HapticFeedback.lightImpact();
    }

    // ✅ Then navigate to biometric setup
    if (mounted) {
      Navigator.pushNamed(context, RouteNames.biometric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🌄 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/wp13202115-elephant-phone-wallpapers 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Image.asset(
                      'assets/icons/zra.png',
                      height: 53,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(
                            'assets/icons/user-circle-solid-240.png'),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Sign-In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.78,
                    maxChildSize: 0.9,
                    minChildSize: 0.6,
                    builder: (_, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 20),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildTextField(
                                  label: '+260 | Phone Number',
                                  controller: _phoneController,
                                  validator: Validators.validatePhone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 15),

                                buildTextField(
                                  label: 'Enter Password',
                                  controller: _passwordController,
                                  validator: Validators.validatePassword,
                                  obscureText: true,
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) =>
                                          setState(() => _rememberMe = v!),
                                    ),
                                    const Text("Remember Me"),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // ✅ Login button
                                ElevatedButton(
                                  onPressed: authController.isLoading
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await authController.signIn(
                                              _phoneController.text.trim(),
                                              _passwordController.text.trim(),
                                              context,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                  child: authController.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : const Text(
                                          "Sign In",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),

                                const SizedBox(height: 25),

                                // ✅ Fingerprint button with improved vibration
                                GestureDetector(
                                  onTap: _handleBiometricTap,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.fingerprint,
                                          color: Colors.grey, size: 65),
                                      SizedBox(height: 10),
                                      Text(
                                        "Use biometrics",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, RouteNames.signup);
                                  },
                                  child: const Text(
                                    "Don't have an account? Create one",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: const Color(0xFF2A61F2),
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
