import 'package:flutter/material.dart';

class BusesPage extends StatelessWidget {
  const BusesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buses")),
      body: const Center(child: Text("This is Buses Page")),
    );
  }
}
