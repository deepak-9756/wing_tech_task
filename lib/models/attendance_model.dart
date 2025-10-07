import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String employeeName;
  final String employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status; // present, late, absent, halfday
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? checkInAddress;
  final String? checkOutAddress;
  final bool isQrScanned;
  final String? notes;
  final int? workingMinutes; // Total working minutes
  final double? distanceFromOffice; // Distance from office in meters

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.isQrScanned = false,
    this.notes,
    this.workingMinutes,
    this.distanceFromOffice,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      employeeId: map['employeeId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      checkIn: map['checkIn'] != null ? (map['checkIn'] as Timestamp).toDate() : null,
      checkOut: map['checkOut'] != null ? (map['checkOut'] as Timestamp).toDate() : null,
      status: map['status'] ?? 'absent',
      checkInLat: map['checkInLat']?.toDouble(),
      checkInLng: map['checkInLng']?.toDouble(),
      checkOutLat: map['checkOutLat']?.toDouble(),
      checkOutLng: map['checkOutLng']?.toDouble(),
      checkInAddress: map['checkInAddress'],
      checkOutAddress: map['checkOutAddress'],
      isQrScanned: map['isQrScanned'] ?? false,
      notes: map['notes'],
      workingMinutes: map['workingMinutes']?.toInt(),
      distanceFromOffice: map['distanceFromOffice']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'employeeName': employeeName,
      'employeeId': employeeId,
      'date': Timestamp.fromDate(date),
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'status': status,
      'checkInLat': checkInLat,
      'checkInLng': checkInLng,
      'checkOutLat': checkOutLat,
      'checkOutLng': checkOutLng,
      'checkInAddress': checkInAddress,
      'checkOutAddress': checkOutAddress,
      'isQrScanned': isQrScanned,
      'notes': notes,
      'workingMinutes': workingMinutes,
      'distanceFromOffice': distanceFromOffice,
    };
  }

  // Calculate working minutes if not stored
  int calculateWorkingMinutes() {
    if (workingMinutes != null) return workingMinutes!;
    if (checkIn != null && checkOut != null) {
      return checkOut!.difference(checkIn!).inMinutes;
    }
    return 0;
  }

  // Format working hours to HH:MM
  String getFormattedWorkingHours() {
    int minutes = calculateWorkingMinutes();
    if (minutes <= 0) return '00:00';
    
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  // Get formatted check-in time
  String getFormattedCheckIn() {
    if (checkIn == null) return 'Not marked';
    return DateFormat('HH:mm').format(checkIn!);
  }

  // Get formatted check-out time
  String getFormattedCheckOut() {
    if (checkOut == null) return 'Not marked';
    return DateFormat('HH:mm').format(checkOut!);
  }

  // Get formatted date
  String getFormattedDate() {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Get day name
  String getDayName() {
    return DateFormat('EEEE').format(date);
  }

  // Check if employee is checked in
  bool get isCheckedIn => checkIn != null;

  // Check if employee is checked out
  bool get isCheckedOut => checkOut != null;

  // Check if attendance is complete (both check-in and check-out)
  bool get isComplete => isCheckedIn && isCheckedOut;

  // Get working hours in decimal format (for calculations)
  double getWorkingHoursDecimal() {
    int minutes = calculateWorkingMinutes();
    return minutes / 60.0;
  }

  // Copy with method for updates
  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? employeeName,
    String? employeeId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    double? checkInLat,
    double? checkInLng,
    double? checkOutLat,
    double? checkOutLng,
    String? checkInAddress,
    String? checkOutAddress,
    bool? isQrScanned,
    String? notes,
    int? workingMinutes,
    double? distanceFromOffice,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
      checkInAddress: checkInAddress ?? this.checkInAddress,
      checkOutAddress: checkOutAddress ?? this.checkOutAddress,
      isQrScanned: isQrScanned ?? this.isQrScanned,
      notes: notes ?? this.notes,
      workingMinutes: workingMinutes ?? this.workingMinutes,
      distanceFromOffice: distanceFromOffice ?? this.distanceFromOffice,
    );
  }

  @override
  String toString() {
    return 'AttendanceModel{id: $id, employeeName: $employeeName, date: ${getFormattedDate()}, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
