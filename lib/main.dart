import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_plantiva/firebase_options.dart';
import 'package:flutter_plantiva/config/app_theme.dart';
import 'package:flutter_plantiva/screens/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PlantivaApp());
}

class PlantivaApp extends StatelessWidget {
  const PlantivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plantiva',
      theme: AppTheme.theme,
      home: const LandingPage(),
    );
  }
}
