import 'package:flutter/material.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Driver Profile
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/driver.png"), // placeholder image
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Driver Name: John Doe", style: TextStyle(fontSize: 18)),
                    Text("Driver ID: D123", style: TextStyle(fontSize: 16)),
                    Text("Bus Assigned: TN 45 AB 1234", style: TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 40),

            // Location Toggle Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isSharing = !isSharing;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSharing ? Colors.red : Colors.green,
              ),
              child: Text(isSharing ? "Stop Sharing Location" : "Enable Location"),
            ),
            const SizedBox(height: 20),

            if (isSharing)
              const Text("📍 Location is being shared...",
                  style: TextStyle(color: Colors.green, fontSize: 16)),

            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}
