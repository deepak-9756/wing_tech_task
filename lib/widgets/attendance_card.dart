import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;
  final bool showDetails;
  final VoidCallback? onTap;

  const AttendanceCard({
    Key? key,
    required this.attendance,
    this.showDetails = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(attendance.date),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(attendance.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      attendance.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInfo(
                      'Check In',
                      attendance.checkIn != null
                          ? DateFormat('HH:mm').format(attendance.checkIn!)
                          : 'Not marked',
                      Icons.login,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildTimeInfo(
                      'Check Out',
                      attendance.checkOut != null
                          ? DateFormat('HH:mm').format(attendance.checkOut!)
                          : 'Not marked',
                      Icons.logout,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              if (showDetails && (attendance.checkIn != null && attendance.checkOut != null)) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Working Hours: ${attendance.getFormattedWorkingHours()}',
                      style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
              if (showDetails && attendance.checkInAddress != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attendance.checkInAddress!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'halfday':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
