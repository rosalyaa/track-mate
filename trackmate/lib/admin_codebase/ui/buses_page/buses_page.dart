import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackmate/admin_codebase/service/bus_management/bus_firestore.dart';

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

  final BusFirestoreService _busService = BusFirestoreService();

  @override
  void dispose() {
    _busNumberController.dispose();
    _plateController.dispose();
    _routeController.dispose();
    super.dispose();
  }

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
                onPressed: _createBus,
                child: const Text("Create Bus"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Create bus in Firestore
  Future<void> _createBus() async {
    final busNo = _busNumberController.text.trim();
    final plate = _plateController.text.trim();
    final route = _routeController.text.trim();

    if (busNo.isEmpty || plate.isEmpty || route.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      await _busService.addBus(
        busNumber: busNo,
        numberPlate: plate,
        route: route,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bus $busNo created successfully")),
      );

      _busNumberController.clear();
      _plateController.clear();
      _routeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// View Bus List
  Widget _buildViewPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _busService.getBuses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No buses found",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final buses = snapshot.data!.docs;

        return ListView.builder(
          itemCount: buses.length,
          itemBuilder: (context, index) {
            var bus = buses[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text("Bus: ${bus['busNumber']}"),
                subtitle: Text(
                    "Plate: ${bus['numberPlate']} | Route: ${bus['route']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await _busService.deleteBus(bus['busNumber']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Bus ${bus['busNumber']} deleted successfully")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
