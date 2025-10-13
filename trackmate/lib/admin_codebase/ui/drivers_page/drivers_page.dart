import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackmate/admin_codebase/service/driver_management/driver_firestore.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  bool showCreateForm = false;

  // Controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedBus;
  final DriverFirestoreService _driverService = DriverFirestoreService();

  List<String> buses = [];

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  void _fetchBuses() {
    _driverService.getBuses().listen((snapshot) {
      List<String> fetchedBuses = [];
      for (var doc in snapshot.docs) {
        var bus = doc.data() as Map<String, dynamic>;
        if (bus['busNumber'] != null) fetchedBuses.add(bus['busNumber']);
      }
      setState(() {
        buses = fetchedBuses;
      });
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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
                  setState(() => showCreateForm = true);
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text("View"),
                onPressed: () {
                  setState(() => showCreateForm = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: showCreateForm ? _buildCreateForm() : _buildViewPage(),
          ),
        ],
      ),
    );
  }

  /// --- CREATE FORM ---
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
                "Create Driver",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: "Driver ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),

              // Bus Assigned Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBus,
                decoration: const InputDecoration(
                  labelText: "Bus Assigned",
                  border: OutlineInputBorder(),
                ),
                items: buses.map((bus) {
                  return DropdownMenuItem(
                    value: bus,
                    child: Text(bus),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBus = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Auto-generate username/password
              Builder(builder: (context) {
                String id = _idController.text.trim();
                String username =
                    id.isNotEmpty ? "$id@sxcce" : "driverid@sxcce";
                String password = id.isNotEmpty ? id : "driverid";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Username: $username",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Password: $password",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                );
              }),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: _createDriver,
                child: const Text("Create Driver"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- CREATE DRIVER LOGIC ---
  Future<void> _createDriver() async {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final bus = _selectedBus;

    if (id.isEmpty || name.isEmpty || phone.isEmpty || bus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final username = "$id@sxcce";
    final password = id;

    try {
      await _driverService.addDriver(
        driverId: id,
        name: name,
        phoneNumber: phone,
        username: username,
        password: password,
        busAssigned: bus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Driver $name added successfully")),
      );

      _idController.clear();
      _nameController.clear();
      _phoneController.clear();
      setState(() {
        _selectedBus = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// --- VIEW DRIVERS ---
  Widget _buildViewPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _driverService.getDrivers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No drivers found",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final drivers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            var driver = drivers[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(driver['name'] ?? ''),
                subtitle: Text(
                    "ID: ${driver['driverId']} | Phone: ${driver['phoneNumber']} | Bus: ${driver['busAssigned']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await _driverService.deleteDriver(driver['driverId']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Driver ${driver['name']} deleted successfully")),
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
