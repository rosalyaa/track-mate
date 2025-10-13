import 'package:cloud_firestore/cloud_firestore.dart';

class DriverFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed location
  static const double fixedLat = 8.19410;
  static const double fixedLng = 77.38510;

  /// Fetch driver details by driverId
  Future<Map<String, dynamic>?> getDriverById(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) return doc.data();
      return null;
    } catch (e) {
      print("Error fetching driver: $e");
      return null;
    }
  }

  /// Fetch driver details by username (case-insensitive)
  Future<Map<String, dynamic>?> getDriverByUsername(String username) async {
    try {
      final snapshot = await _firestore.collection('drivers').get();

      QueryDocumentSnapshot<Map<String, dynamic>>? matchedDriver;
      try {
        matchedDriver = snapshot.docs.firstWhere(
          (doc) =>
              (doc.data()['username'] ?? '').toString().toLowerCase() ==
              username.toLowerCase(),
        );
      } catch (e) {
        matchedDriver = null;
      }

      if (matchedDriver != null) return matchedDriver.data();
      return null;
    } catch (e) {
      print("Error fetching driver by username: $e");
      return null;
    }
  }

  /// Pin driver location (always fixed)
  Future<void> pinFixedLocation(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).set({
        'lat': fixedLat,
        'lng': fixedLng,
      }, SetOptions(merge: true));

      print(
          "Driver location pinned to fixed coordinates: $fixedLat, $fixedLng");
    } catch (e) {
      print("Error pinning driver location: $e");
    }
  }

  /// Update bus location (always fixed)
  Future<void> updateBusLocation(String busNumber) async {
    try {
      await _firestore.collection('buses').doc(busNumber).set({
        'lat': fixedLat,
        'lng': fixedLng,
      }, SetOptions(merge: true));

      print("Bus location updated to fixed coordinates: $fixedLat, $fixedLng");
    } catch (e) {
      print("Error updating bus location: $e");
    }
  }

  /// Update all students in a bus with driver location (always fixed)
  Future<void> updateStudentsLocation(String busNumber) async {
    try {
      final studentsSnapshot = await _firestore
          .collection('students')
          .where('busNumber', isEqualTo: busNumber)
          .get();

      for (var student in studentsSnapshot.docs) {
        await student.reference.update({
          'driverLat': fixedLat,
          'driverLng': fixedLng,
        });
      }

      print(
          "All students updated with fixed driver location: $fixedLat, $fixedLng");
    } catch (e) {
      print("Error updating students location: $e");
    }
  }
}
