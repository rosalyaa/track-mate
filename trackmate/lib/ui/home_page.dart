import 'package:flutter/material.dart';
import 'package:trackmate/service/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: const Center(child: Text("Welcome, Admin!")),
    );
  }
}
