import 'package:cloud_firestore/cloud_firestore.dart';

class DriverFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



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

  /// Pin driver location 
  Future<void> pinLocation(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).set({
        'lat': lat,
        'lng': lng,
      }, SetOptions(merge: true));

      print(
          "Driver location pinned : $lat, $lng");
    } catch (e) {
      print("Error pinning driver location: $e");
    }
  }

  /// Update bus location 
  Future<void> updateBusLocation(String busNumber) async {
    try {
      await _firestore.collection('buses').doc(busNumber).set({
        'lat': lat,
        'lng': lng,
      }, SetOptions(merge: true));

      print("Bus location updated: $lat, $lng");
    } catch (e) {
      print("Error updating bus location: $e");
    }
  }

  /// Update all students in a bus with driver location
  Future<void> updateStudentsLocation(String busNumber) async {
    try {
      final studentsSnapshot = await _firestore
          .collection('students')
          .where('busNumber', isEqualTo: busNumber)
          .get();

      for (var student in studentsSnapshot.docs) {
        await student.reference.update({
          'driverLat': lat,
          'driverLng': lng,
        });
      }

      print(
          "All students updated with driver location: $lat, $lng");
    } catch (e) {
      print("Error updating students location: $e");
    }
  }
}














































































































































































   const double lat = 8.19410;
   const double lng = 77.38510;