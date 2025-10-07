import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/attendance_model.dart';
import '../../models/office_settings_model.dart';
import '../../widgets/qr_scanner_widget.dart';

class MarkAttendanceScreen extends StatefulWidget {
  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final LocationService locationService = Get.find();
  final FirestoreService firestoreService = Get.find();
  final AuthService authService = Get.find();
  
  Position? currentPosition;
  OfficeSettingsModel? officeSettings;
  bool isLoading = true;
  bool isWithinOffice = false;
  String currentAddress = "";
  bool qrScanned = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadOfficeSettings();
  }

  Future<void> _initializeLocation() async {
    currentPosition = await locationService.getCurrentLocation();
    if (currentPosition != null) {
      currentAddress = await locationService.getAddressFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
      _checkIfWithinOffice();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadOfficeSettings() async {
    officeSettings = await firestoreService.getOfficeSettings();
    if (officeSettings != null && currentPosition != null) {
      _checkIfWithinOffice();
    }
  }

  void _checkIfWithinOffice() {
    if (officeSettings != null && currentPosition != null) {
      isWithinOffice = locationService.isWithinOfficeRadius(
        currentPosition!,
        officeSettings!.officeLat,
        officeSettings!.officeLng,
        officeSettings!.geofenceRadius,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location status card
                  Card(
                    color: isWithinOffice ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isWithinOffice ? Icons.location_on : Icons.location_off,
                                color: isWithinOffice ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isWithinOffice ? 'Within Office Area' : 'Outside Office Area',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isWithinOffice ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Current Location: $currentAddress'),
                          if (officeSettings != null)
                            Text('Office: ${officeSettings!.officeAddress}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // QR Code scanner section
                  if (officeSettings?.isQrRequired == true)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR Code Verification Required',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: qrScanned ? null : _scanQRCode,
                              icon: Icon(qrScanned ? Icons.check : Icons.qr_code_scanner),
                              label: Text(qrScanned ? 'QR Verified' : 'Scan QR Code'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: qrScanned ? Colors.green : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 30),

                  // Mark attendance button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canMarkAttendance() ? _markAttendance : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Mark Attendance',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canMarkAttendance() ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Requirements checklist
                  Text(
                    'Requirements:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  _buildRequirement('Within office area', isWithinOffice),
                  if (officeSettings?.isQrRequired == true)
                    _buildRequirement('QR code scanned', qrScanned),
                ],
              ),
            ),
    );
  }

  Widget _buildRequirement(String text, bool completed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  bool _canMarkAttendance() {
    bool locationOk = isWithinOffice;
    bool qrOk = officeSettings?.isQrRequired != true || qrScanned;
    return locationOk && qrOk;
  }

  void _scanQRCode() {
    Get.to(() => QRScannerWidget())?.then((result) {
      if (result != null) {
        // Validate QR code with today's code
        firestoreService.validateQrCode(result).then((isValid) {
          if (isValid) {
            setState(() {
              qrScanned = true;
            });
            Get.snackbar('Success', 'QR Code verified successfully');
          } else {
            Get.snackbar('Error', 'Invalid QR Code');
          }
        });
      }
    });
  }

  void _markAttendance() async {
    if (!_canMarkAttendance()) {
      Get.snackbar('Error', 'Please fulfill all requirements');
      return;
    }

    // Check if already marked today
    AttendanceModel? todayAttendance = await firestoreService.getTodayAttendance(
      authService.currentUser.value!.uid,
    );

    DateTime now = DateTime.now();
    String status = 'present';

    // Check if late
    if (officeSettings != null) {
      List<String> lateTime = officeSettings!.lateThreshold.split(':');
      DateTime lateThreshold = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(lateTime[0]),
        int.parse(lateTime[1]),
      );

      if (now.isAfter(lateThreshold)) {
        status = 'late';
      }
    }

    AttendanceModel attendance;

    if (todayAttendance == null) {
      // First time marking today - Check In
      attendance = AttendanceModel(
        id: '${authService.currentUser.value!.uid}_${now.toString().split(' ')[0]}',
        userId: authService.currentUser.value!.uid,
        employeeName: authService.currentUser.value!.name,
        employeeId: authService.currentUser.value!.employeeId,
        date: now,
        checkIn: now,
        status: status,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: currentAddress,
        isQrScanned: qrScanned,
      );
    } else {
      // Already checked in - Check Out
      attendance = AttendanceModel(
        id: todayAttendance.id,
        userId: todayAttendance.userId,
        employeeName: todayAttendance.employeeName,
        employeeId: todayAttendance.employeeId,
        date: todayAttendance.date,
        checkIn: todayAttendance.checkIn,
        checkOut: now,
        status: todayAttendance.status,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        address: currentAddress,
        isQrScanned: qrScanned,
      );
    }

    String? error = await firestoreService.markAttendance(attendance);

    if (error == null) {
      Get.back();
      Get.snackbar(
        'Success',
        todayAttendance == null ? 'Check-in successful' : 'Check-out successful',
      );
    } else {
      Get.snackbar('Error', error);
    }
  }
}
