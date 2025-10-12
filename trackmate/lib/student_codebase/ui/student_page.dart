import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackmate/student_codebase/ui/map_eta.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String studentName = "John Doe";
  String rollNo = "22CS101";
  String busNo = "Bus-05";
  String boardingPoint = "Main Gate";

  LatLng? pinnedLocation;

  Future<void> _pinLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location services!")),
      );
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get current position
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      pinnedLocation = LatLng(pos.latitude, pos.longitude);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location pinned successfully!")),
    );
  }

  void _openMapView() {
    if (pinnedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pin your location first")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(location: pinnedLocation!),
      ),
    );
  }

  void _logout() {
    Navigator.pop(context); // back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $studentName", style: const TextStyle(fontSize: 18)),
            Text("Roll No: $rollNo", style: const TextStyle(fontSize: 18)),
            Text("Bus No: $busNo", style: const TextStyle(fontSize: 18)),
            Text("Boarding Point: $boardingPoint", style: const TextStyle(fontSize: 18)),
            Text(
              "Pinned Location: ${pinnedLocation != null ? '${pinnedLocation!.latitude}, ${pinnedLocation!.longitude}' : 'Not pinned yet'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            if (pinnedLocation == null)
              ElevatedButton(
                onPressed: _pinLocation,
                child: const Text("Pin Location"),
              ),

            ElevatedButton(
              onPressed: _openMapView,
              child: const Text("View Location"),
            ),
          ],
        ),
      ),
    );
  }
}
