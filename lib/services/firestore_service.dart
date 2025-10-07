import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';
import '../models/office_settings_model.dart';
import '../models/user_model.dart';

class FirestoreService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Attendance CRUD
  Future<String?> markAttendance(AttendanceModel attendance) async {
    try {
      await _firestore.collection('attendance').doc(attendance.id).set(attendance.toMap());
      return null;
    } catch (e) {
      return 'Failed to mark attendance: $e';
    }
  }

  Future<String?> updateAttendance(AttendanceModel attendance) async {
    try {
      await _firestore.collection('attendance').doc(attendance.id).update(attendance.toMap());
      return null;
    } catch (e) {
      return 'Failed to update attendance: $e';
    }
  }

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot query = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return AttendanceModel.fromMap(query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get today\'s attendance: $e');
      return null;
    }
  }

  Stream<AttendanceModel?> getTodayAttendanceStream(String userId) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return AttendanceModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Stream<List<AttendanceModel>> getAttendanceHistory(String userId, {int limit = 30}) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AttendanceModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Office Settings
  Future<OfficeSettingsModel?> getOfficeSettings() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('settings').doc('office').get();
      if (doc.exists) {
        return OfficeSettingsModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get office settings: $e');
      return null;
    }
  }

  // Employees management
  Stream<List<UserModel>> getAllEmployees() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
  
  Future<String?> deleteEmployee(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      // Optionally also delete their attendance records
      return null;
    } catch (e) {
      return 'Failed to delete employee: $e';
    }
  }
  
  // QR code generation and validation methods would go here...

}
