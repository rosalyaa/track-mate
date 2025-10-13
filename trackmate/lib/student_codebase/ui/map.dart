import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  final String? studentId; // Firestore document ID of student
  final String busNumber; // Bus document ID in Firestore
  final LatLng? studentLocation; // Optional pre-provided student location

  const MapPage({
    super.key,
    this.studentId,
    required this.busNumber,
    this.studentLocation,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng? _studentLocation;
  LatLng? _busLocation;
  Set<Marker> _markers = {};
  BitmapDescriptor? _busIcon;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusIcon();
    _fetchLocations();
  }

  /// Load custom bus icon
  Future<void> _loadBusIcon() async {
    _busIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/bus.png', // Ensure this is declared in pubspec.yaml
    );
  }

  /// Fetch student and bus locations from Firestore
  Future<void> _fetchLocations() async {
    try {
      // --- Fetch Student Location ---
      if (widget.studentLocation != null) {
        _studentLocation = widget.studentLocation;
      } else if (widget.studentId != null) {
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(widget.studentId)
            .get();

        if (studentDoc.exists) {
          final data = studentDoc.data()!;
          final pinned = data['pinnedLocation'];
          if (pinned != null) {
            final lat = pinned['lat'];
            final lng = pinned['lng'];
            if (lat != null && lng != null) {
              _studentLocation = LatLng(lat.toDouble(), lng.toDouble());
            }
          }
        }
      }

      // --- Fetch Bus Location ---
      final busDoc = await FirebaseFirestore.instance
          .collection('buses')
          .doc(widget.busNumber)
          .get();

      if (busDoc.exists) {
        final data = busDoc.data()!;
        final lat = data['driverLat'] ?? data['lat'];
        final lng = data['driverLng'] ?? data['lng'];
        if (lat != null && lng != null) {
          _busLocation = LatLng(lat.toDouble(), lng.toDouble());
        }
      }

      // --- Update Markers ---
      _updateMarkers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching locations: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Update map markers
  void _updateMarkers() {
    final markers = <Marker>{};

    // Student marker
    if (_studentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('student'),
          position: _studentLocation!,
          infoWindow: const InfoWindow(title: "Your Pinned Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    // Bus marker
    if (_busLocation != null) {
      final icon = _busIcon ?? BitmapDescriptor.defaultMarker;
      markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: _busLocation!,
          infoWindow: InfoWindow(title: "Bus ${widget.busNumber}"),
          icon: icon,
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  /// Open Google Maps externally with directions from bus to student
  Future<void> _showETA() async {
    if (_studentLocation == null || _busLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Locations not available")),
      );
      return;
    }

    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
      "&origin=${_busLocation!.latitude},${_busLocation!.longitude}"
      "&destination=${_studentLocation!.latitude},${_studentLocation!.longitude}"
      "&travelmode=driving",
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _studentLocation == null && _busLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Choose initial camera target
    final LatLng initialTarget =
        _studentLocation ?? _busLocation ?? const LatLng(8.19421, 77.38513);

    return Scaffold(
      appBar: AppBar(title: const Text("Bus Tracking")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
