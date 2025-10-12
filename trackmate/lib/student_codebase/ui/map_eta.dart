import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final LatLng location;
  const MapPage({super.key, required this.location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;

  Future<void> _showETA() async {
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=${widget.location.latitude},${widget.location.longitude}&travelmode=driving",
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pinned Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.location,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("pinned"),
                position: widget.location,
              ),
            },
            onMapCreated: (controller) {
              _controller = controller;
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _showETA,
              label: const Text("ETA"),
              icon: const Icon(Icons.access_time),
            ),
          ),
        ],
      ),
    );
  }
}
