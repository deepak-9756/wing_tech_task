import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wing_tech_task/models/settings_model.dart';
import 'package:wing_tech_task/models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/timer_service.dart';
import '../../widgets/custom_button.dart';
import 'employee_profile_screen.dart';
import 'attendance_history_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _selectedIndex = 0;
  late TimerService _timerService;
  bool _timerInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize timer service
    _timerService = TimerService(
      onTick: (duration) {
        setState(() {});
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadData();
      // Initialize timer from Firebase after loading attendance data
      await Future.delayed(const Duration(milliseconds: 500));
      _initializeTimerFromAttendance();
    });
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  void _loadData() {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid != null) {
      context.read<AttendanceProvider>().fetchTodayAttendance(uid);
      context.read<SettingsProvider>().fetchSettings();
    }
  }

  /// Initialize timer from attendance check-in time
  void _initializeTimerFromAttendance() {
    if (_timerInitialized) return;

    final attendance = context.read<AttendanceProvider>().todayAttendance;

    // If checked in but not checked out
    if (attendance?.checkInTime != null && attendance?.checkOutTime == null) {
      print('✅ Timer found: ${attendance!.checkInTime}');

      // Calculate elapsed time from check-in
      final checkInTime = attendance.checkInTime!;
      final now = DateTime.now();
      final elapsed = now.difference(checkInTime);

      // Set timer with calculated elapsed time
      _timerService.setElapsedTime(elapsed);
      _timerService.resume();

      _timerInitialized = true;
      print(
        '🕐 Timer started with elapsed: ${TimerService.formatDuration(elapsed)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildHomeTab() : _buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer3<UserProvider, AttendanceProvider, SettingsProvider>(
      builder: (
        context,
        userProvider,
        attendanceProvider,
        settingsProvider,
        _,
      ) {
        final user = userProvider.user;
        final attendance = attendanceProvider.todayAttendance;
        final settings = settingsProvider.settings;

        // Initialize timer if not already done
        if (!_timerInitialized &&
            attendance?.checkInTime != null &&
            attendance?.checkOutTime == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeTimerFromAttendance();
            }
          });
        }

        // Stop timer if checked out
        if (attendance?.checkOutTime != null && _timerService.isRunning) {
          _timerService.pause();
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ← HEADER SECTION - Profile + Timer
                _buildHeaderSection(user, attendance),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text:
                            attendance?.checkInTime != null
                                ? '✓ Checked In'
                                : 'Check In',
                        isLoading: attendanceProvider.isLoading,
                        onPressed:
                            attendance?.checkInTime == null
                                ? () => _handleCheckIn(context)
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text:
                            attendance?.checkOutTime != null
                                ? '✓ Checked Out'
                                : 'Check Out',
                        isLoading: attendanceProvider.isLoading,
                        onPressed:
                            attendance?.checkInTime != null &&
                                    attendance?.checkOutTime == null
                                ? () => _handleCheckOut(context)
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ← ATTENDANCE STATUS SECTION
                _buildAttendanceStatusCard(attendance),
                const SizedBox(height: 20),

                // ← OFFICE TIMING SECTION
                _buildOfficeTimingCard(settings),
                const SizedBox(height: 20),

                // ← BUTTONS SECTION
                _buildActionButtons(context, attendance, attendanceProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header with Profile Photo + Timer
  Widget _buildHeaderSection(UserModel? user, AttendanceModel? attendance) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  user?.profileImageUrl != null
                      ? NetworkImage(user!.profileImageUrl!)
                      : null,
              backgroundColor: Colors.white,
              child:
                  user?.profileImageUrl == null
                      ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade600,
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 16),

          // Text + Timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.name ?? 'Employee',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Timer Badge
                if (attendance?.checkInTime != null &&
                    attendance?.checkOutTime == null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Working • ${TimerService.formatDuration(_timerService.elapsed)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Attendance Status Card
  Widget _buildAttendanceStatusCard(AttendanceModel? attendance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Attendance',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _getStatusBackgroundColor(attendance?.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  attendance?.status ?? 'Not Marked',
                  style: TextStyle(
                    color: _getStatusTextColor(attendance?.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Check-in Details
          if (attendance?.checkInTime != null) ...[
            _buildDetailRow(
              icon: Icons.login,
              iconColor: Colors.green,
              label: 'Check-in',
              value: DateFormat('hh:mm a').format(attendance!.checkInTime!),
              subValue: attendance.checkInAddress,
              distanceValue:
                  attendance.distanceFromOffice != null
                      ? '${(attendance.distanceFromOffice! / 1000).toStringAsFixed(2)} km'
                      : null,
              distanceColor:
                  attendance.isWithinGeofence == true
                      ? Colors.green
                      : Colors.orange,
            ),
            const SizedBox(height: 16),
          ],

          // Check-out Details
          if (attendance?.checkOutTime != null) ...[
            _buildDetailRow(
              icon: Icons.logout,
              iconColor: Colors.red,
              label: 'Check-out',
              value: DateFormat('hh:mm a').format(attendance!.checkOutTime!),
              subValue: attendance.checkOutAddress,
            ),
            const SizedBox(height: 16),
          ] else if (attendance?.checkInTime != null) ...[
            _buildDetailRow(
              icon: Icons.logout,
              iconColor: Colors.grey,
              label: 'Check-out',
              value: 'Pending',
              subValue: null,
            ),
            const SizedBox(height: 16),
          ],

          // Working Hours
          if (attendance?.totalHours != null)
            _buildDetailRow(
              icon: Icons.schedule,
              iconColor: Colors.blue,
              label: 'Working Hours',
              value: '${attendance!.totalHours!.toStringAsFixed(2)} hrs',
              subValue: null,
            ),
        ],
      ),
    );
  }

  /// Office Timing Card
  Widget _buildOfficeTimingCard(SettingsModel settings) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Office Schedule',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimingBox(
                  icon: Icons.schedule,
                  label: 'Start Time',
                  value: settings.officeStartTime ?? '09:00',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimingBox(
                  icon: Icons.schedule_send,
                  label: 'End Time',
                  value: settings.officeEndTime ?? '17:00',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimingBox(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: '${settings.officeHours.toStringAsFixed(0)}h',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Timing Box
  Widget _buildTimingBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Detail Row (Check-in/Check-out)
  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subValue,
    String? distanceValue,
    Color? distanceColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (distanceValue != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: distanceColor),
                    const SizedBox(width: 4),
                    Text(
                      distanceValue,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: distanceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Action Buttons
  Widget _buildActionButtons(
    BuildContext context,
    AttendanceModel? attendance,
    AttendanceProvider attendanceProvider,
  ) {
    return Column(
      children: [
        // Attendance History Button
        SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AttendanceHistoryScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade300, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: Colors.purple.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Attendance History',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.purple.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Check-in / Check-out Buttons
      ],
    );
  }

  /// Status Colors
  Color _getStatusBackgroundColor(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green.shade100;
      case 'Half Day':
        return Colors.orange.shade100;
      case 'Late':
        return Colors.red.shade100;
      case 'Absent':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case 'Present':
        return Colors.green.shade700;
      case 'Half Day':
        return Colors.orange.shade700;
      case 'Late':
        return Colors.red.shade700;
      case 'Absent':
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildProfileTab() {
    return const EmployeeProfileScreen();
  }

  void _handleCheckIn(BuildContext context) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    final userProvider = context.read<UserProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (uid != null && userProvider.user != null) {
      final success = await context.read<AttendanceProvider>().markCheckIn(
        uid,
        userProvider.user!.name,
        settingsProvider.settings.officeHours,
        settingsProvider.settings.officeLatitude ?? 28.6139,
        settingsProvider.settings.officeLongitude ?? 77.2090,
        settingsProvider.settings.geofenceRadius ?? 500,
      );

      if (mounted) {
        if (success) {
          // Reset and start timer
          _timerService.reset();
          _timerService.start();
          _timerInitialized = true;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Check-in successful with GPS location!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<AttendanceProvider>().error ?? 'Check-in failed',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleCheckOut(BuildContext context) async {
    final uid = context.read<AuthProvider>().currentUser?.uid;
    final settingsProvider = context.read<SettingsProvider>();

    if (uid != null) {
      final success = await context.read<AttendanceProvider>().markCheckOut(
        uid,
        settingsProvider.settings.officeHours,
        settingsProvider.settings.officeLatitude ?? 28.6139,
        settingsProvider.settings.officeLongitude ?? 77.2090,
        settingsProvider.settings.geofenceRadius ?? 500,
      );

      if (mounted) {
        if (success) {
          _timerService.pause();
          _timerInitialized = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Check-out successful with GPS location!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<AttendanceProvider>().error ?? 'Check-out failed',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String? status) {
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
