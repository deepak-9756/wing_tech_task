import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/firestore_service.dart';
import '../services/gps_service.dart'; // ← ADD THIS
import 'package:intl/intl.dart';

class AttendanceProvider extends ChangeNotifier {
  final _firestoreService = FirestoreService();

  AttendanceModel? _todayAttendance;
  List<AttendanceModel> _monthAttendance = [];
  List<AttendanceModel> _allEmployeeAttendance = [];
  bool _isLoading = false;
  String? _error;

  AttendanceModel? get todayAttendance => _todayAttendance;
  List<AttendanceModel> get monthAttendance => _monthAttendance;
  List<AttendanceModel> get allEmployeeAttendance => _allEmployeeAttendance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodayAttendance(String employeeId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(today);
      _todayAttendance = await _firestoreService.getAttendance(
        employeeId,
        formattedDate,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update attendance record (Admin)
  Future<bool> updateAttendanceRecord({
    required String employeeId,
    required String date,
    required DateTime? checkInTime,
    required DateTime? checkOutTime,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      print('📝 Starting update for $employeeId on $date');
      print('Check-in: $checkInTime, Check-out: $checkOutTime');

      // Call Firestore update
      final success = await _firestoreService.updateAttendance(
        employeeId: employeeId,
        date: date,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      );

      print('🔄 Update result: $success');

      if (success) {
        // Refresh the list
        await fetchAllEmployeeAttendance(date);
        print('✅ Attendance refreshed');
      } else {
        _error = 'Failed to update attendance';
        print('❌ Update failed');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      print('❌ Exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ← UPDATED - With GPS parameters
  Future<bool> markCheckIn(
    String employeeId,
    String employeeName,
    double officeHours,
    double officeLat,
    double officeLon,
    double geofenceRadius,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get GPS location
      final locationData = await GPSService.getCurrentLocation();
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Calculate distance from office
      final distance = GPSService.calculateDistance(
        locationData['latitude'],
        locationData['longitude'],
        officeLat,
        officeLon,
      );

      // Check if within geofence
      final isWithin = GPSService.isWithinGeofence(
        locationData['latitude'],
        locationData['longitude'],
        officeLat,
        officeLon,
        geofenceRadius,
      );

      var attendance = _todayAttendance;
      if (attendance == null) {
        attendance = AttendanceModel(
          id: '${formattedDate}_$employeeId',
          employeeId: employeeId,
          employeeName: employeeName,
          date: now,
          checkInTime: now,
          status: 'Present',
          // ← GPS fields
          checkInLatitude: locationData['latitude'],
          checkInLongitude: locationData['longitude'],
          checkInAddress: locationData['address'],
          checkInAccuracy: locationData['accuracy'],
          distanceFromOffice: distance,
          isWithinGeofence: isWithin,
        );
      } else {
        attendance = attendance.copyWith(
          checkInTime: now,
          checkInLatitude: locationData['latitude'],
          checkInLongitude: locationData['longitude'],
          checkInAddress: locationData['address'],
          checkInAccuracy: locationData['accuracy'],
          distanceFromOffice: distance,
          isWithinGeofence: isWithin,
        );
      }

      await _firestoreService.saveAttendance(
        employeeId,
        formattedDate,
        attendance,
      );
      _todayAttendance = attendance;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ← UPDATED - With GPS parameters
  Future<bool> markCheckOut(
    String employeeId,
    double officeHours,
    double officeLat,
    double officeLon,
    double geofenceRadius,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_todayAttendance != null && _todayAttendance!.checkInTime != null) {
        // Get GPS location
        final locationData = await GPSService.getCurrentLocation();
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd').format(now);

        // Calculate distance from office
        final distance = GPSService.calculateDistance(
          locationData['latitude'],
          locationData['longitude'],
          officeLat,
          officeLon,
        );

        // Check if within geofence
        final isWithin = GPSService.isWithinGeofence(
          locationData['latitude'],
          locationData['longitude'],
          officeLat,
          officeLon,
          geofenceRadius,
        );

        final totalHours =
            now.difference(_todayAttendance!.checkInTime!).inMinutes / 60;
        final status = totalHours < officeHours ? 'Half Day' : 'Present';

        final updatedAttendance = _todayAttendance!.copyWith(
          checkOutTime: now,
          status: status,
          totalHours: totalHours,
          // ← GPS fields
          checkOutLatitude: locationData['latitude'],
          checkOutLongitude: locationData['longitude'],
          checkOutAddress: locationData['address'],
          checkOutAccuracy: locationData['accuracy'],
        );

        await _firestoreService.saveAttendance(
          employeeId,
          formattedDate,
          updatedAttendance,
        );
        _todayAttendance = updatedAttendance;

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Please check in first';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMonthAttendance(String employeeId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monthAttendance = await _firestoreService.getMonthAttendance(employeeId);
    } catch (e) {
      _error = e.toString();
      print("error ajvk ${_error}");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllEmployeeAttendance(String date) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;

    try {
      _allEmployeeAttendance = await _firestoreService.getAllEmployeeAttendance(
        date,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateAttendance(
    String employeeId,
    String date,
    AttendanceModel attendance,
    double officeHours,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      late String status;
      late double? totalHours;

      if (attendance.checkInTime != null && attendance.checkOutTime != null) {
        totalHours =
            attendance.checkOutTime!
                .difference(attendance.checkInTime!)
                .inMinutes /
            60;
        status = totalHours < officeHours ? 'Half Day' : 'Present';
      } else if (attendance.checkInTime != null) {
        status = 'Present';
      } else {
        status = 'Absent';
      }

      final updatedAttendance = attendance.copyWith(
        status: status,
        totalHours: totalHours,
      );

      await _firestoreService.saveAttendance(
        employeeId,
        date,
        updatedAttendance,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
