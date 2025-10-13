import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add student to Firestore
  Future<void> addStudent({
    required String name,
    required String roll,
    required String boardingPoint,
    required String busNumber, // new field
    required String username,
    required String password,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('students').doc(roll).set({
        'name': name,
        'rollNumber': roll,
        'boardingPoint': boardingPoint,
        'busNumber': busNumber,
        'username': username,
        'password': password,
        'photoUrl': photoUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add student: $e");
    }
  }

  /// Get all students (real-time stream)
  Stream<QuerySnapshot> getStudents() {
    return _firestore
        .collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete student by roll number
  Future<void> deleteStudent(String roll) async {
    await _firestore.collection('students').doc(roll).delete();
  }

  /// Get buses (real-time stream)
  Stream<QuerySnapshot> getBuses() {
    return _firestore
        .collection('buses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
