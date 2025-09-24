import 'package:flutter/material.dart';

class BusesPage extends StatefulWidget {
  const BusesPage({super.key});

  @override
  State<BusesPage> createState() => _BusesPageState();
}

class _BusesPageState extends State<BusesPage> {
  bool showCreateForm = false;

  // Controllers
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buttons
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Create"),
                onPressed: () {
                  setState(() {
                    showCreateForm = true;
                  });
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text("View"),
                onPressed: () {
                  setState(() {
                    showCreateForm = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Page content
          Expanded(
            child: showCreateForm ? _buildCreateForm() : _buildViewPage(),
          ),
        ],
      ),
    );
  }

  /// Create Bus Form
  Widget _buildCreateForm() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Create Bus",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _busNumberController,
                decoration: const InputDecoration(
                  labelText: "Bus Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: "Number Plate",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: "Route Allocated",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  final busNo = _busNumberController.text.trim();
                  final plate = _plateController.text.trim();
                  final route = _routeController.text.trim();

                  if (busNo.isEmpty || plate.isEmpty || route.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  // TODO: Save bus details to Firestore/DB
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Bus $busNo created (Plate: $plate, Route: $route)"),
                    ),
                  );

                  _busNumberController.clear();
                  _plateController.clear();
                  _routeController.clear();
                },
                child: const Text("Create Bus"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// View Bus List (later connect to Firestore)
  Widget _buildViewPage() {
    return const Center(
      child: Text(
        "List of Buses will appear here",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
