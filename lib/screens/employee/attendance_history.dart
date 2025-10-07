import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';
import '../../widgets/attendance_card.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final AuthService authService = Get.find<AuthService>();
  final FirestoreService firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<List<AttendanceModel>>(
        stream: firestoreService.getAttendanceHistory(authService.userId, limit: 50),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No attendance records found', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
            );
          }

          List<AttendanceModel> attendances = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              return AttendanceCard(attendance: attendances[index], showDetails: true);
            },
          );
        },
      ),
    );
  }
}
