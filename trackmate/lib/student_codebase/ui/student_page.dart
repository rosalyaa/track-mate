import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackmate/student_codebase/backend/studentApp_firestore.dart';
import 'package:trackmate/student_codebase/ui/map.dart';

class StudentHomePage extends StatefulWidget {
  final String username;
  const StudentHomePage({super.key, required this.username});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? studentData;
  LatLng? pinnedLocation;
  bool loading = true;

  // Fixed location coordinates
  static const double fixedLat = 8.19421;
  static const double fixedLng = 77.38513;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  /// Fetch student data from Firestore
  Future<void> _fetchStudentData() async {
    try {
      final data = await _firestoreService.getStudentByUsername(widget.username);
      if (data != null) {
        setState(() {
          studentData = data;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Student data not found")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// Pin the fixed location (on button press)
  Future<void> _pinLocation() async {
    if (studentData == null) return;

    setState(() {
      pinnedLocation = const LatLng(fixedLat, fixedLng);
    });

    // Save the fixed location in Firestore
    await _firestoreService.pinFixedLocation(studentData!['rollNumber']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location successfully pinned!")),
    );
  }

  /// Open MapPage
  void _openMapView() {
    if (pinnedLocation == null || studentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pin your location first")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(
          studentLocation: pinnedLocation!, 
          busNumber: studentData!['busNumber'],
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : studentData == null
              ? const Center(child: Text("Student data not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard("Name", studentData!['name']),
                      _infoCard("Roll No", studentData!['rollNumber']),
                      _infoCard("Bus No", studentData!['busNumber']),
                      _infoCard("Boarding Point", studentData!['boardingPoint']),
                      if (pinnedLocation != null)
                        _infoCard(
                          "Pinned Location",
                          '${pinnedLocation!.latitude}, ${pinnedLocation!.longitude}',
                        ),
                      const SizedBox(height: 20),
                      if (pinnedLocation == null)
                        ElevatedButton.icon(
                          onPressed: _pinLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text("Pin My Location"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _openMapView,
                        icon: const Icon(Icons.map),
                        label: const Text("View on Map"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// Info card widget
  Widget _infoCard(String title, String value) {
    Icon leadingIcon;
    switch (title) {
      case "Name":
        leadingIcon = const Icon(Icons.person, color: Colors.deepPurple);
        break;
      case "Roll No":
        leadingIcon = const Icon(Icons.badge, color: Colors.deepPurple);
        break;
      case "Bus No":
        leadingIcon = const Icon(Icons.directions_bus, color: Colors.deepPurple);
        break;
      case "Boarding Point":
        leadingIcon = const Icon(Icons.place, color: Colors.deepPurple);
        break;
      case "Pinned Location":
        leadingIcon = const Icon(Icons.location_pin, color: Colors.deepPurple);
        break;
      default:
        leadingIcon = const Icon(Icons.info, color: Colors.deepPurple);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        leading: leadingIcon,
      ),
    );
  }
}
