import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackmate/driver_codebase/backend/driverApp_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverHomePage extends StatefulWidget {
  final String driverId; // Passed from login
  const DriverHomePage({super.key, required this.driverId});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final DriverFirestoreService _driverService = DriverFirestoreService();

  Map<String, dynamic>? driverData;
  bool isSharing = false;
  String locationStatus = "Location not shared";

  

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    final data = await _driverService.getDriverById(widget.driverId);
    if (data != null) setState(() => driverData = data);
  }

  Future<void> _pinLocation() async {
    if (driverData == null) return;

    String busNumber = driverData!['busAssigned'];

    // Update driver, bus, and students with  location
    await _driverService.pinLocation(widget.driverId);
    await _driverService.updateBusLocation(busNumber);
    await _driverService.updateStudentsLocation(busNumber);

    setState(() {
      locationStatus = "Location successfully shared!";
    });

    print("location pinned for driver, bus, and students.");
  }

  void _toggleSharing() {
    setState(() => isSharing = !isSharing);

    if (isSharing) {
      _pinLocation();
    } else {
      setState(() => locationStatus = "Location not shared");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: driverData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // DRIVER INFO CARD
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Driver Info",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[700]),
                          ),
                          const SizedBox(height: 10),
                          _infoRow("Name", driverData!['name']),
                          _infoRow("Driver ID", widget.driverId),
                          _infoRow("Bus Assigned", driverData!['busAssigned']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // LOCATION STATUS CARD
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.deepPurple[50],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Location Status",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locationStatus,
                            style: TextStyle(
                                fontSize: 16,
                                color: isSharing
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // TOGGLE BUTTON
                  ElevatedButton(
                    onPressed: _toggleSharing,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: isSharing ? Colors.red : Colors.green,
                    ),
                    child: Text(
                      isSharing
                          ? "Stop Sharing Location"
                          : "Enable Location",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),

                  // LOGOUT BUTTON
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text("$title:",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
