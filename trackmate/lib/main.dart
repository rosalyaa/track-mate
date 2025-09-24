import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackmate/admin_codebase/ui/login/login_page.dart';
import 'firebase_options.dart';


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
    print("main");
    return MaterialApp
    (
      title: 'TrackMate - Admin',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(),
    );
  }
}
