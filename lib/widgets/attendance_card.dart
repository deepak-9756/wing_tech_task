import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/attendance_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceCard({Key? key, required this.attendance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attendance.employeeName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(attendance.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    attendance.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (attendance.checkInTime != null)
              Text(
                'Check-in: ${DateFormat('hh:mm a').format(attendance.checkInTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (attendance.checkOutTime != null)
              Text(
                'Check-out: ${DateFormat('hh:mm a').format(attendance.checkOutTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Half Day':
        return Colors.orange;
      case 'Late':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
