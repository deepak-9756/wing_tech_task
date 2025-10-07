import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';
import 'employee_management.dart';
import 'attendance_reports.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService authService = Get.find();
  final FirestoreService firestoreService = Get.find();
  String? todayQRCode;

  @override
  void initState() {
    super.initState();
    _generateTodayQR();
  }

  Future<void> _generateTodayQR() async {
    String? qrData = await firestoreService.generateDailyQr();
    setState(() {
      todayQRCode = qrData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
                      'Welcome Admin, ${authService.currentUser.value?.name ?? "Admin"}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage employees and track attendance',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Today's QR Code
            if (todayQRCode != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s QR Code',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: 200,
                        child: QrImageView(
                          data: todayQRCode!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      Text(
                        'Employees need to scan this QR code for attendance',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Today's attendance summary
            StreamBuilder<List<AttendanceModel>>(
              stream: firestoreService.getAllAttendanceToday(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<AttendanceModel> attendances = snapshot.data!;
                  int present = attendances.where((a) => a.status == 'present').length;
                  int late = attendances.where((a) => a.status == 'late').length;
                  
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Summary',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Present', present, Colors.green),
                              _buildSummaryItem('Late', late, Colors.orange),
                              _buildSummaryItem('Total', attendances.length, Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Loading today\'s summary...'),
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
                    onPressed: () => Get.to(() => EmployeeManagementScreen()),
                    icon: Icon(Icons.people),
                    label: Text('Manage Employees'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => AttendanceReportsScreen()),
                    icon: Icon(Icons.analytics),
                    label: Text('View Reports'),
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

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
