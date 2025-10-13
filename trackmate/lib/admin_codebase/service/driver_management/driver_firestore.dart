import 'package:cloud_firestore/cloud_firestore.dart';

class DriverFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add driver to Firestore
  Future<void> addDriver({
    required String driverId,
    required String name,
    required String phoneNumber,
    required String username,
    required String password,
    required String busAssigned,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('drivers').doc(driverId).set({
        'driverId': driverId,
        'name': name,
        'phoneNumber': phoneNumber,
        'username': username,
        'password': password,
        'busAssigned': busAssigned,
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add driver: $e");
    }
  }

  /// Get all drivers (real-time stream)
  Stream<QuerySnapshot> getDrivers() {
    return _firestore
        .collection('drivers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete driver
  Future<void> deleteDriver(String driverId) async {
    await _firestore.collection('drivers').doc(driverId).delete();
  }

  /// Get all buses for dropdown
  Stream<QuerySnapshot> getBuses() {
    return _firestore
        .collection('buses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
