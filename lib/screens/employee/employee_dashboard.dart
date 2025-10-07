import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';


class EmployeeDashboard extends StatelessWidget {
  final AuthService authService = Get.find();
  final FirestoreService firestoreService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${authService.currentUser.value?.name ?? "Employee"}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Employee ID: ${authService.currentUser.value?.employeeId ?? "N/A"}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Today's attendance status
            StreamBuilder<AttendanceModel?>(
              stream: firestoreService.getTodayAttendanceStream(authService.currentUser.value!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  AttendanceModel attendance = snapshot.data!;
                  return Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Today\'s Status: ${attendance.status.toUpperCase()}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          if (attendance.checkIn != null)
                            Text('Check In: ${attendance.checkIn!.hour}:${attendance.checkIn!.minute.toString().padLeft(2, '0')}'),
                          if (attendance.checkOut != null)
                            Text('Check Out: ${attendance.checkOut!.hour}:${attendance.checkOut!.minute.toString().padLeft(2, '0')}'),
                        ],
                      ),
                    ),
                  );
                }
                return Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No attendance marked today',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
            SizedBox(height: 30),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => MarkAttendanceScreen()),
                    icon: Icon(Icons.location_on),
                    label: Text('Mark Attendance'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => AttendanceHistoryScreen()),
                    icon: Icon(Icons.history),
                    label: Text('View History'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
