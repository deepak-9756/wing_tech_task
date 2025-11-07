import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../models/settings_model.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'role': role,
      'createdAt': DateTime.now(),
    });
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, UserModel user) async {
    await _firestore.collection('users').doc(uid).update(user.toMap());
  }

  Future<List<UserModel>> getAllEmployees() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'employee')
              .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update attendance record (Admin)
  /// Update attendance record (Admin only)
  Future<bool> updateAttendance({
    required String employeeId,
    required String date,
    required DateTime? checkInTime,
    required DateTime? checkOutTime,
  }) async {
    try {
      print('🔄 Updating attendance for $employeeId on date: $date');

      final updates = <String, dynamic>{};

      // Always include these for debugging
      updates['updatedAt'] = DateTime.now();

      // Set check-in time
      if (checkInTime != null) {
        updates['checkInTime'] = checkInTime;
        print('✅ Setting Check-in: $checkInTime');
      }

      // Set check-out time
      if (checkOutTime != null) {
        updates['checkOutTime'] = checkOutTime;
        print('✅ Setting Check-out: $checkOutTime');
      }

      // Calculate total hours and status
      if (checkInTime != null && checkOutTime != null) {
        final totalHours = checkOutTime.difference(checkInTime).inMinutes / 60;
        updates['totalHours'] = totalHours;

        print('📊 Total Hours: ${totalHours.toStringAsFixed(2)}');

        // Set status based on hours
        if (totalHours >= 8) {
          updates['status'] = 'Present';
        } else if (totalHours > 0) {
          updates['status'] = 'Half Day';
        } else {
          updates['status'] = 'Absent';
        }
      } else if (checkInTime != null && checkOutTime == null) {
        updates['status'] = 'Present';
      } else if (checkInTime == null && checkOutTime == null) {
        updates['status'] = 'Absent';
      }

      print('📤 Updates to send: $updates');
      print('📍 Document path: attendance/$date/records/$employeeId');

      // Update in Firestore - EXACT PATH
      final docRef = _firestore
          .collection('attendance')
          .doc(date)
          .collection('records')
          .doc(employeeId);

      print('🔍 Checking document exists...');
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('✅ Document exists, updating...');
        await docRef.update(updates);
        print('✅✅ Firestore updated successfully!');
        return true;
      } else {
        print('❌ Document does not exist at path: $date/$employeeId');
        print('📝 Creating document instead...');
        await docRef.set(updates, SetOptions(merge: true));
        print('✅ Document created');
        return true;
      }
    } catch (e) {
      print('❌ Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Attendance operations
  Future<void> saveAttendance(
    String employeeId,
    String date,
    AttendanceModel attendance,
  ) async {
    await _firestore
        .collection('attendance')
        .doc(date)
        .collection('records')
        .doc(employeeId)
        .set(attendance.toMap());
  }

  Future<AttendanceModel?> getAttendance(String employeeId, String date) async {
    try {
      final doc =
          await _firestore
              .collection('attendance')
              .doc(date)
              .collection('records')
              .doc(employeeId)
              .get();

      if (doc.exists) {
        return AttendanceModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<AttendanceModel>> getMonthAttendance(String employeeId) async {
    try {
      print('📊 Fetching: $employeeId');

      final now = DateTime.now();
      final futures = <Future<AttendanceModel?>>[];

      // Parallel queries
      for (int i = 0; i < 30; i++) {
        final dateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(Duration(days: i)));

        futures.add(
          _firestore
              .collection('attendance')
              .doc(dateStr)
              .collection('records')
              .doc(employeeId)
              .get()
              .then(
                (doc) =>
                    doc.exists
                        ? AttendanceModel.fromMap(doc.data()!, doc.id)
                        : null,
              )
              .catchError((_) => null),
        );
      }

      final results = await Future.wait(futures);
      final records = results.whereType<AttendanceModel>().toList();

      records.sort((a, b) => b.date.compareTo(a.date));

      print(
        '✅ Total: ${records.length}, Returning: ${records.take(10).length}',
      );
      return records.take(10).toList();
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Future<List<AttendanceModel>> getMonthAttendance(String employeeId) async {
  //   try {
  //     print('📊 Fetching: $employeeId');

  //     List<AttendanceModel> records = [];
  //     final now = DateTime.now();

  //     for (int i = 0; i < 30; i++) {
  //       final dateStr = DateFormat(
  //         'yyyy-MM-dd',
  //       ).format(now.subtract(Duration(days: i)));

  //       try {
  //         final doc =
  //             await _firestore
  //                 .collection('attendance')
  //                 .doc(dateStr)
  //                 .collection('records')
  //                 .doc(employeeId)
  //                 .get();

  //         if (doc.exists) {
  //           records.add(AttendanceModel.fromMap(doc.data()!, doc.id));
  //         }
  //       } catch (e) {
  //         // Skip
  //       }
  //     }

  //     records.sort((a, b) => b.date.compareTo(a.date));
  //     return records.take(10).toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

  Future<List<AttendanceModel>> getAllEmployeeAttendance(String date) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('attendance')
              .doc(date)
              .collection('records')
              .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Settings operations
  Future<SettingsModel> getSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('office').get();
      if (doc.exists) {
        return SettingsModel.fromMap(doc.data()!);
      }
      return SettingsModel();
    } catch (e) {
      return SettingsModel();
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _firestore.collection('settings').doc('office').set(settings.toMap());
  }
}
