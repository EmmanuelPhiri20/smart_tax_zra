import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/route_names.dart';
import '../../core/theme/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+260');
  final _tpinController = TextEditingController();
  bool _acceptTerms = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _tpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🐘 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/wp13202115-elephant-phone-wallpapers 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.35)),

          // 🔹 Main content
          SafeArea(
            child: Column(
              children: [
                // 🔹 ZRA logo
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

                // 🔹 Avatar + title
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
                        "Create Account",
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

                // 🔹 Form section
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
                              children: [
                                buildTextField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                  validator: Validators.validateName,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 12),

                                buildTextField(
                                  label: '+260 | Phone Number',
                                  controller: _phoneController,
                                  validator: Validators.validatePhone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 12),

                                buildTextField(
                                  label: 'Enter T-PIN',
                                  controller: _tpinController,
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Please enter T-PIN'
                                      : null,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),

                                buildTextField(
                                  label: 'example@gmail.com',
                                  controller: _emailController,
                                  validator: Validators.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 12),

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
                                      value: _acceptTerms,
                                      onChanged: (v) =>
                                          setState(() => _acceptTerms = v!),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'I agree to the Terms and Conditions',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // ✅ Sign-up button
                                ElevatedButton(
                                  onPressed: authController.isLoading ||
                                          !_acceptTerms
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await authController.signUp(
                                              _nameController.text.trim(),
                                              _phoneController.text.trim(),
                                              _tpinController.text.trim(),
                                              _emailController.text.trim(),
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
                                  child: const Text(
                                    "Sign-up",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, RouteNames.login);
                                  },
                                  child: const Text(
                                    "Already have an account? Sign in",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Text(
                                  "Help?\nTerms of Use",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
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

          // 🌀 Floating loader overlay (top center)
          if (authController.isLoading)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.5,
                  ),
                ),
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
