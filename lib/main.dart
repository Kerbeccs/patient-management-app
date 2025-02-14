import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/views/splash_screen.dart';
import 'ui/views/patient_dashboard.dart';
import 'ui/views/login_screen.dart';
import 'ui/views/signup_screen.dart';
import 'viewmodels/auth_viewmodels.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Uses system setting
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/patient': (context) => const PatientDashboard(),
        '/login': (context) => LoginScreen(), // Ensure LoginScreen is included
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
