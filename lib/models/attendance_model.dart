class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // 'Present', 'Half Day', 'Absent', 'Late'
  final double? totalHours;

  // ← NEW FIELDS - GPS Location
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? checkInAddress;
  final double? checkInAccuracy; // in meters
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String? checkOutAddress;
  final double? checkOutAccuracy;
  final double? distanceFromOffice; // in meters
  final bool? isWithinGeofence; // inside office area?

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.status = 'Absent',
    this.totalHours,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAddress,
    this.checkInAccuracy,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAddress,
    this.checkOutAccuracy,
    this.distanceFromOffice,
    this.isWithinGeofence,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      checkInTime:
          map['checkInTime'] != null
              ? (map['checkInTime'] as dynamic).toDate()
              : null,
      checkOutTime:
          map['checkOutTime'] != null
              ? (map['checkOutTime'] as dynamic).toDate()
              : null,
      status: map['status'] ?? 'Absent',
      totalHours: map['totalHours']?.toDouble(),

      // NEW - GPS fields
      checkInLatitude: map['checkInLatitude']?.toDouble(),
      checkInLongitude: map['checkInLongitude']?.toDouble(),
      checkInAddress: map['checkInAddress'],
      checkInAccuracy: map['checkInAccuracy']?.toDouble(),
      checkOutLatitude: map['checkOutLatitude']?.toDouble(),
      checkOutLongitude: map['checkOutLongitude']?.toDouble(),
      checkOutAddress: map['checkOutAddress'],
      checkOutAccuracy: map['checkOutAccuracy']?.toDouble(),
      distanceFromOffice: map['distanceFromOffice']?.toDouble(),
      isWithinGeofence: map['isWithinGeofence'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'totalHours': totalHours,

      // NEW - GPS fields
      'checkInLatitude': checkInLatitude,
      'checkInLongitude': checkInLongitude,
      'checkInAddress': checkInAddress,
      'checkInAccuracy': checkInAccuracy,
      'checkOutLatitude': checkOutLatitude,
      'checkOutLongitude': checkOutLongitude,
      'checkOutAddress': checkOutAddress,
      'checkOutAccuracy': checkOutAccuracy,
      'distanceFromOffice': distanceFromOffice,
      'isWithinGeofence': isWithinGeofence,
    };
  }

  AttendanceModel copyWith({
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    double? totalHours,
    double? checkInLatitude,
    double? checkInLongitude,
    String? checkInAddress,
    double? checkInAccuracy,
    double? checkOutLatitude,
    double? checkOutLongitude,
    String? checkOutAddress,
    double? checkOutAccuracy,
    double? distanceFromOffice,
    bool? isWithinGeofence,
  }) {
    return AttendanceModel(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      totalHours: totalHours ?? this.totalHours,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkInAddress: checkInAddress ?? this.checkInAddress,
      checkInAccuracy: checkInAccuracy ?? this.checkInAccuracy,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      checkOutAddress: checkOutAddress ?? this.checkOutAddress,
      checkOutAccuracy: checkOutAccuracy ?? this.checkOutAccuracy,
      distanceFromOffice: distanceFromOffice ?? this.distanceFromOffice,
      isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
    );
  }
}
