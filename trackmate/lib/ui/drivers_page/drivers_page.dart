import 'package:flutter/material.dart';

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
  List<String> buses = ["Bus 1", "Bus 2", "Bus 3"]; 
  // TODO: Fetch this list from Firestore (bus collection)

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

  /// Create Driver Form
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

              // Photo Upload (placeholder)
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text("Upload Photo"),
                onPressed: () {
                  // TODO: integrate image picker
                },
              ),
              const SizedBox(height: 20),

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
                onPressed: () {
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

                  // TODO: Save driver to Firestore
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Driver $name created (Bus: $bus, Username: $username, Password: $password)",
                      ),
                    ),
                  );

                  _idController.clear();
                  _nameController.clear();
                  _phoneController.clear();
                  setState(() {
                    _selectedBus = null;
                  });
                },
                child: const Text("Create Driver"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// View Driver List (later fetch from Firestore)
  Widget _buildViewPage() {
    return const Center(
      child: Text(
        "List of Drivers will appear here",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
