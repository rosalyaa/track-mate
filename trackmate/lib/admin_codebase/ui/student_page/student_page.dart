import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackmate/admin_codebase/service/student_management/student_firestore.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  bool showCreateForm = false;
  final FirestoreService _firestoreService = FirestoreService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _boardingController = TextEditingController();

  // Selected bus for dropdown
  String? _selectedBus;
  List<String> buses = [];

  // Auto-generated username & password
  String username = "rollnumber@sxcce";
  String password = "rollnumber";

  @override
  void initState() {
    super.initState();

    // Listen to roll number changes for username/password
    _rollController.addListener(() {
      final roll = _rollController.text.trim();
      setState(() {
        username = roll.isNotEmpty ? "$roll@sxcce" : "rollnumber@sxcce";
        password = roll.isNotEmpty ? roll : "rollnumber";
      });
    });

    // Fetch buses from Firestore
    _firestoreService.getBuses().listen((snapshot) {
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
    _nameController.dispose();
    _rollController.dispose();
    _boardingController.dispose();
    super.dispose();
  }

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

          // Content area
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Student",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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

              // Bus dropdown
              DropdownButtonFormField<String>(
                value: _selectedBus,
                decoration: const InputDecoration(
                  labelText: "Bus Number",
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

              // Auto-generated credentials
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Username: $username",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Password: $password",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                onPressed: _createStudent,
                child: const Text("Create Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- FIRESTORE CREATE LOGIC ---
  Future<void> _createStudent() async {
    String name = _nameController.text.trim();
    String roll = _rollController.text.trim();
    String boarding = _boardingController.text.trim();
    String? bus = _selectedBus;

    if (name.isEmpty || roll.isEmpty || boarding.isEmpty || bus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      await _firestoreService.addStudent(
        name: name,
        roll: roll,
        boardingPoint: boarding,
        busNumber: bus,
        username: username,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student $name added successfully")));

      _nameController.clear();
      _rollController.clear();
      _boardingController.clear();
      setState(() {
        _selectedBus = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// --- VIEW STUDENTS ---
  Widget _buildViewPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No students found",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            var student = students[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(student['name'] ?? ''),
                subtitle: Text(
                    "Roll: ${student['rollNumber']} | Boarding: ${student['boardingPoint']} | Bus: ${student['busNumber']}"),
                trailing: Text(student['username'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }
}
