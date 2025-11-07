import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/settings_provider.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAttendance();
  }

  void _loadAttendance() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchAllEmployeeAttendance(dateStr);
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendance();
    }
  }

  void _showEditDialog(BuildContext context, AttendanceModel attendance) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => _EditAttendanceDialog(
            attendance: attendance,
            selectedDate: _selectedDate,
            onSave: (checkInTime, checkOutTime) {
              final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

              print('🔄 Updating:');
              print('   Employee: ${attendance.employeeName}');
              print('   Check-in: $checkInTime');
              print('   Check-out: $checkOutTime');

              context
                  .read<AttendanceProvider>()
                  .updateAttendanceRecord(
                    employeeId: attendance.employeeId,
                    date: dateStr,
                    checkInTime: checkInTime,
                    checkOutTime: checkOutTime,
                  )
                  .then((success) {
                    if (success) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Attendance updated successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      _loadAttendance();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<AttendanceProvider>().error ??
                                'Failed to update attendance',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  })
                  .catchError((e) {
                    print('❌ Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Attendance Management'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildDatePickerSection(),
            Expanded(
              child: Consumer2<AttendanceProvider, SettingsProvider>(
                builder: (context, attendanceProvider, settingsProvider, _) {
                  if (attendanceProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final attendanceList =
                      attendanceProvider.allEmployeeAttendance;

                  if (attendanceList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text('No attendance records found'),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: attendanceList.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final attendance = attendanceList[index];
                      return _buildAttendanceCard(
                        context,
                        attendance,
                        () => _showEditDialog(context, attendance),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300, width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Change',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    AttendanceModel attendance,
    VoidCallback onEdit,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attendance.employeeName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${attendance.employeeId}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBackgroundColor(attendance.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        attendance.status,
                        style: TextStyle(
                          color: _getStatusTextColor(attendance.status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeDetail(
                        icon: Icons.login,
                        label: 'Check-in',
                        value:
                            attendance.checkInTime != null
                                ? DateFormat(
                                  'hh:mm a',
                                ).format(attendance.checkInTime!)
                                : 'Not marked',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeDetail(
                        icon: Icons.logout,
                        label: 'Check-out',
                        value:
                            attendance.checkOutTime != null
                                ? DateFormat(
                                  'hh:mm a',
                                ).format(attendance.checkOutTime!)
                                : 'Not marked',
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (attendance.totalHours != null)
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${attendance.totalHours!.toStringAsFixed(2)} hrs',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green.shade100;
      case 'Half Day':
        return Colors.orange.shade100;
      case 'Late':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green.shade700;
      case 'Half Day':
        return Colors.orange.shade700;
      case 'Late':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}

/// Edit Attendance Dialog - NO TOGGLE
class _EditAttendanceDialog extends StatefulWidget {
  final AttendanceModel attendance;
  final DateTime selectedDate;
  final Function(DateTime?, DateTime?) onSave;

  const _EditAttendanceDialog({
    required this.attendance,
    required this.selectedDate,
    required this.onSave,
  });

  @override
  State<_EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<_EditAttendanceDialog> {
  late TimeOfDay _checkInTime;
  late TimeOfDay _checkOutTime;

  @override
  void initState() {
    super.initState();
    _checkInTime =
        widget.attendance.checkInTime != null
            ? TimeOfDay.fromDateTime(widget.attendance.checkInTime!)
            : const TimeOfDay(hour: 9, minute: 0);

    _checkOutTime =
        widget.attendance.checkOutTime != null
            ? TimeOfDay.fromDateTime(widget.attendance.checkOutTime!)
            : const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime,
    );
    if (picked != null) {
      setState(() {
        _checkInTime = picked;
      });
    }
  }

  Future<void> _selectCheckOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime,
    );
    if (picked != null) {
      setState(() {
        _checkOutTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Attendance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            widget.attendance.employeeName,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),

            // Check-in Time Picker
            _buildTimePickerField(
              label: 'Check-in Time',
              value: _checkInTime,
              onTap: _selectCheckInTime,
              icon: Icons.login,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            // Check-out Time Picker
            _buildTimePickerField(
              label: 'Check-out Time',
              value: _checkOutTime,
              onTap: _selectCheckOutTime,
              icon: Icons.logout,
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Click on time to change',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Save'),
          onPressed: () {
            final checkInDateTime = DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              _checkInTime.hour,
              _checkInTime.minute,
            );

            final checkOutDateTime = DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              _checkOutTime.hour,
              _checkOutTime.minute,
            );

            widget.onSave(checkInDateTime, checkOutDateTime);
          },
        ),
      ],
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required TimeOfDay value,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.05),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value.format(context),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
              Icon(Icons.access_time, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
