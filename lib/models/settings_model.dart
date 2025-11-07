class SettingsModel {
  final double officeHours;
  final String? officeStartTime;
  final String? officeEndTime;
  final List<String> workingDays;

  // ← NEW FIELDS
  final double? officeLatitude; // Office GPS location
  final double? officeLongitude;
  final double? geofenceRadius; // in meters (default 500m)

  SettingsModel({
    this.officeHours = 8.0,
    this.officeStartTime = '09:00',
    this.officeEndTime = '17:00',
    this.workingDays = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
    ],
    this.officeLatitude = 30.3275, // Example: Delhi coordinates
    this.officeLongitude = 78.0325,
    this.geofenceRadius = 500, // 500 meters
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      officeHours: (map['officeHours'] ?? 8.0).toDouble(),
      officeStartTime: map['officeStartTime'] ?? '09:00',
      officeEndTime: map['officeEndTime'] ?? '17:00',
      workingDays: List<String>.from(
        map['workingDays'] ??
            ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      ),
      officeLatitude: map['officeLatitude']?.toDouble() ?? 30.3275,
      officeLongitude: map['officeLongitude']?.toDouble() ?? 78.0325,
      geofenceRadius: map['geofenceRadius']?.toDouble() ?? 500,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'officeHours': officeHours,
      'officeStartTime': officeStartTime,
      'officeEndTime': officeEndTime,
      'workingDays': workingDays,
      'officeLatitude': officeLatitude,
      'officeLongitude': officeLongitude,
      'geofenceRadius': geofenceRadius,
    };
  }
}
