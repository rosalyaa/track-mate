import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get student data by username
  Future<Map<String, dynamic>?> getStudentByUsername(String username) async {
    try {
      final query = await _db
          .collection('students')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch student: $e");
    }
  }

  /// Pin fixed location in Firestore
  Future<void> pinFixedLocation(String rollNumber) async {
    const double fixedLat = 8.19421; 
    const double fixedLng = 77.38513; 

    await _db.collection('students').doc(rollNumber).set({
      'pinnedLocation': {
        'lat': fixedLat,
        'lng': fixedLng,
      }
    }, SetOptions(merge: true));
  }

  /// Optionally: update other fields or bus location if needed
  Future<void> updateLocation(String rollNumber, double lat, double lng) async {
    await _db.collection('students').doc(rollNumber).set({
      'pinnedLocation': {
        'lat': lat,
        'lng': lng,
      }
    }, SetOptions(merge: true));
  }
}
