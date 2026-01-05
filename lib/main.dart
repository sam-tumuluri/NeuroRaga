import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neurorga/theme.dart';
import 'package:neurorga/screens/splash_screen.dart';
import 'package:neurorga/services/backend_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase only when a backend is configured.
  if (BackendConfig.backendEnabled) {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroRāga',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
