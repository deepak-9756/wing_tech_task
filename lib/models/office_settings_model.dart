import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeSettingsModel {
  final String id;
  final String officeStartTime;
  final String officeEndTime;
  final String lateThreshold;
  final String earlyLeaveThreshold;
  final double officeLat;
  final double officeLng;
  final double geofenceRadius; // in meters
  final String officeAddress;
  final bool isQrRequired;
  final bool isLocationRequired;
  final int minimumWorkingMinutes; // in minutes
  final List<String> workingDays; // Mon, Tue, Wed, etc.
  final DateTime updatedAt;
  final String? adminId;
  final Map<String, dynamic>? breakSettings;

  OfficeSettingsModel({
    required this.id,
    required this.officeStartTime,
    required this.officeEndTime,
    required this.lateThreshold,
    required this.earlyLeaveThreshold,
    required this.officeLat,
    required this.officeLng,
    required this.geofenceRadius,
    required this.officeAddress,
    this.isQrRequired = true,
    this.isLocationRequired = true,
    this.minimumWorkingMinutes = 480, // 8 hours default
    this.workingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    required this.updatedAt,
    this.adminId,
    this.breakSettings,
  });

  factory OfficeSettingsModel.fromMap(Map<String, dynamic> map) {
    return OfficeSettingsModel(
      id: map['id'] ?? 'office',
      officeStartTime: map['officeStartTime'] ?? '09:00',
      officeEndTime: map['officeEndTime'] ?? '18:00',
      lateThreshold: map['lateThreshold'] ?? '09:30',
      earlyLeaveThreshold: map['earlyLeaveThreshold'] ?? '17:30',
      officeLat: map['officeLat']?.toDouble() ?? 0.0,
      officeLng: map['officeLng']?.toDouble() ?? 0.0,
      geofenceRadius: map['geofenceRadius']?.toDouble() ?? 100.0,
      officeAddress: map['officeAddress'] ?? '',
      isQrRequired: map['isQrRequired'] ?? true,
      isLocationRequired: map['isLocationRequired'] ?? true,
      minimumWorkingMinutes: map['minimumWorkingMinutes']?.toInt() ?? 480,
      workingDays: List<String>.from(map['workingDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      adminId: map['adminId'],
      breakSettings: map['breakSettings'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'officeStartTime': officeStartTime,
      'officeEndTime': officeEndTime,
      'lateThreshold': lateThreshold,
      'earlyLeaveThreshold': earlyLeaveThreshold,
      'officeLat': officeLat,
      'officeLng': officeLng,
      'geofenceRadius': geofenceRadius,
      'officeAddress': officeAddress,
      'isQrRequired': isQrRequired,
      'isLocationRequired': isLocationRequired,
      'minimumWorkingMinutes': minimumWorkingMinutes,
      'workingDays': workingDays,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'adminId': adminId,
      'breakSettings': breakSettings,
    };
  }

  // Check if current day is working day
  bool isWorkingDay([DateTime? date]) {
    DateTime checkDate = date ?? DateTime.now();
    String dayName = _getDayName(checkDate.weekday);
    return workingDays.contains(dayName);
  }

  // Get day name from weekday number
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Mon';
    }
  }

  // Check if current time is within office hours
  bool isWithinOfficeHours([DateTime? dateTime]) {
    DateTime checkTime = dateTime ?? DateTime.now();
    
    // Parse office start and end times
    List<String> startParts = officeStartTime.split(':');
    List<String> endParts = officeEndTime.split(':');
    
    DateTime startTime = DateTime(
      checkTime.year,
      checkTime.month,
      checkTime.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    
    DateTime endTime = DateTime(
      checkTime.year,
      checkTime.month,
      checkTime.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    
    return checkTime.isAfter(startTime) && checkTime.isBefore(endTime);
  }

  // Check if employee is late
  bool isLateCheckIn([DateTime? checkInTime]) {
    DateTime checkTime = checkInTime ?? DateTime.now();
    
    List<String> thresholdParts = lateThreshold.split(':');
    DateTime lateThresholdTime = DateTime(
      checkTime.year,
      checkTime.month,
      checkTime.day,
      int.parse(thresholdParts[0]),
      int.parse(thresholdParts[1]),
    );
    
    return checkTime.isAfter(lateThresholdTime);
  }

  // Check if employee is leaving early
  bool isEarlyLeave([DateTime? checkOutTime]) {
    DateTime checkTime = checkOutTime ?? DateTime.now();
    
    List<String> thresholdParts = earlyLeaveThreshold.split(':');
    DateTime earlyThresholdTime = DateTime(
      checkTime.year,
      checkTime.month,
      checkTime.day,
      int.parse(thresholdParts[0]),
      int.parse(thresholdParts[1]),
    );
    
    return checkTime.isBefore(earlyThresholdTime);
  }

  // Get formatted minimum working hours
  String getFormattedMinimumWorkingHours() {
    int hours = minimumWorkingMinutes ~/ 60;
    int minutes = minimumWorkingMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Get working days as formatted string
  String getWorkingDaysString() {
    return workingDays.join(', ');
  }

  // Copy with method for updates
  OfficeSettingsModel copyWith({
    String? id,
    String? officeStartTime,
    String? officeEndTime,
    String? lateThreshold,
    String? earlyLeaveThreshold,
    double? officeLat,
    double? officeLng,
    double? geofenceRadius,
    String? officeAddress,
    bool? isQrRequired,
    bool? isLocationRequired,
    int? minimumWorkingMinutes,
    List<String>? workingDays,
    DateTime? updatedAt,
    String? adminId,
    Map<String, dynamic>? breakSettings,
  }) {
    return OfficeSettingsModel(
      id: id ?? this.id,
      officeStartTime: officeStartTime ?? this.officeStartTime,
      officeEndTime: officeEndTime ?? this.officeEndTime,
      lateThreshold: lateThreshold ?? this.lateThreshold,
      earlyLeaveThreshold: earlyLeaveThreshold ?? this.earlyLeaveThreshold,
      officeLat: officeLat ?? this.officeLat,
      officeLng: officeLng ?? this.officeLng,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      officeAddress: officeAddress ?? this.officeAddress,
      isQrRequired: isQrRequired ?? this.isQrRequired,
      isLocationRequired: isLocationRequired ?? this.isLocationRequired,
      minimumWorkingMinutes: minimumWorkingMinutes ?? this.minimumWorkingMinutes,
      workingDays: workingDays ?? this.workingDays,
      updatedAt: updatedAt ?? this.updatedAt,
      adminId: adminId ?? this.adminId,
      breakSettings: breakSettings ?? this.breakSettings,
    );
  }

  @override
  String toString() {
    return 'OfficeSettingsModel{id: $id, officeAddress: $officeAddress, workingDays: $workingDays}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfficeSettingsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
