import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/views/splash_screen.dart';
import 'ui/views/patient_dashboard.dart';
import 'ui/views/login_screen.dart';
import 'ui/views/signup_screen.dart';
import 'ui/views/doctor_dashboard.dart';
import 'viewmodels/auth_viewmodels.dart';
import 'viewmodels/booking_view_model.dart';
import 'viewmodels/doctor_appointments_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthViewModel(), lazy: false),
        ChangeNotifierProvider(create: (context) => BookingViewModel()),
        ChangeNotifierProvider(
            create: (context) => DoctorAppointmentsViewModel()),
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
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/patient': (context) => const PatientDashboard(),
        '/doctor': (context) => const DoctorDashboard(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
