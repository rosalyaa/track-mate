import 'package:cloud_firestore/cloud_firestore.dart';

class BusFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a bus to Firestore
  Future<void> addBus({
    required String busNumber,
    required String numberPlate,
    required String route,
  }) async {
    try {
      // Use busNumber as the document ID
      await _firestore.collection('buses').doc(busNumber).set({
        'busNumber': busNumber,
        'numberPlate': numberPlate,
        'route': route,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add bus: $e");
    }
  }

  /// Get all buses as a stream (real-time)
  Stream<QuerySnapshot> getBuses() {
    return _firestore
        .collection('buses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete a bus by bus number
  Future<void> deleteBus(String busNumber) async {
    await _firestore.collection('buses').doc(busNumber).delete();
  }
}
