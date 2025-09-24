import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  bool showCreateForm = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _boardingController = TextEditingController();

  String? photoPath; // (for now just keep path, later integrate file picker)

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buttons: Create & View
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
                    showCreateForm = false; // later load student list
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content depending on choice
          Expanded(
            child: showCreateForm ? _buildCreateForm() : _buildViewPage(),
          ),
        ],
      ),
    );
  }

  /// Student Create Form
  Widget _buildCreateForm() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create Student",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _rollController,
                decoration: const InputDecoration(
                  labelText: "Roll Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _boardingController,
                decoration: const InputDecoration(
                  labelText: "Boarding Point",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // Photo Upload (later integrate file picker)
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text("Upload Photo"),
                onPressed: () {
                  // TODO: integrate image picker
                },
              ),
              const SizedBox(height: 20),

              // Auto-generated credentials
              Builder(builder: (context) {
                String roll = _rollController.text.trim();
                String username =
                    roll.isNotEmpty ? "$roll@sxcce" : "rollnumber@sxcce";
                String password = roll.isNotEmpty ? roll : "rollnumber";

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
                    backgroundColor: Colors.deepPurple),
                onPressed: () {
                  String name = _nameController.text.trim();
                  String roll = _rollController.text.trim();
                  String boarding = _boardingController.text.trim();
                  String username = "$roll@sxcce";
                  String password = roll;

                  if (name.isEmpty || roll.isEmpty || boarding.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Fill all fields")));
                    return;
                  }

                  // TODO: Save student to database (Firestore or your DB)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Student $name created with username $username")));
                },
                child: const Text("Create Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// View Students Page (later fetch list)
  Widget _buildViewPage() {
    return const Center(
      child: Text(
        "List of Students will appear here",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
