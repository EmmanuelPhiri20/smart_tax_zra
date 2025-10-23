import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_pay_zra/views/home/dashboard_screen.dart';
import 'firebase_options.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/dashboard_controller.dart';
//import 'controllers/filing_controller.dart';
//import 'controllers/payment_controller.dart';
//import 'controllers/chat_controller.dart';

// Views
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
//import 'views/auth/forgot_password_screen.dart';
//import 'views/auth/otp_screen.dart';
//import 'views/auth/biometric_setup.dart';
//import 'views/home/dashboard_screen.dart';



// Core
import 'core/constants/route_names.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        //ChangeNotifierProvider(create: (_) => FilingController()),
        //ChangeNotifierProvider(create: (_) => PaymentController()),
        //ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: MaterialApp(
        title: 'Zambia Tax Compliance',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: RouteNames.login,
        routes: {
          RouteNames.login: (context) => const LoginScreen(),
          RouteNames.signup: (context) => const SignUpScreen(),
          //RouteNames.forgotPassword: (context) => ForgotPasswordScreen(),
          //RouteNames.otp: (context) => OtpScreen(phoneNumber: ''),
          //RouteNames.biometricSetup: (context) => BiometricSetupScreen(),
          RouteNames.dashboard: (context) => const DashboardScreen(),
        },
        //onGenerateRoute: (settings) {
        //if (settings.name == RouteNames.otp) {
        //final phoneNumber = settings.arguments as String;
        //return MaterialPageRoute(
        //builder: (context) => OtpScreen(phoneNumber: phoneNumber),
        //);
        //}
        //return null;
        //},
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
