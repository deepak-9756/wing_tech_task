import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wing_tech_task/screens/admin/mployee_list_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import 'attendance_management_screen.dart';
import 'settings_screen.dart';
import 'add_employee_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    context.read<AttendanceProvider>().fetchAllEmployeeAttendance(todayDate);
    context.read<UserProvider>().getAllEmployees();
    context.read<SettingsProvider>().fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Stats Cards
                _buildStatsSection(),
                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActionsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      elevation: 0,
      backgroundColor: Colors.blue.shade600,
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Welcome Admin',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Header Section
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Stats Section
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                icon: Icons.people,
                label: 'Total Employees',
                color: Colors.blue,
                builder:
                    (context) => Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        if (userProvider.isLoading) {
                          return const SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          );
                        }
                        return Text(
                          userProvider.employeeCount.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        );
                      },
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                icon: Icons.check_circle,
                label: 'Present Today',
                color: Colors.green,
                builder:
                    (context) => Consumer<AttendanceProvider>(
                      builder: (context, attendanceProvider, _) {
                        final presentCount =
                            attendanceProvider.allEmployeeAttendance
                                .where((a) => a.status == 'Present')
                                .length;
                        return Text(
                          presentCount.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                icon: Icons.schedule,
                label: 'Half Day',
                color: Colors.orange,
                builder:
                    (context) => Consumer<AttendanceProvider>(
                      builder: (context, attendanceProvider, _) {
                        final halfDayCount =
                            attendanceProvider.allEmployeeAttendance
                                .where((a) => a.status == 'Half Day')
                                .length;
                        return Text(
                          halfDayCount.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        );
                      },
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                icon: Icons.close,
                label: 'Absent',
                color: Colors.red,
                builder:
                    (context) => Consumer<AttendanceProvider>(
                      builder: (context, attendanceProvider, _) {
                        final absentCount =
                            attendanceProvider.allEmployeeAttendance
                                .where((a) => a.status == 'Absent')
                                .length;
                        return Text(
                          absentCount.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Stat Box Widget
  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required Color color,
    required Widget Function(BuildContext) builder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          builder(context),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActionGrid(),
        const SizedBox(height: 16),
        _buildLogoutButton(),
      ],
    );
  }

  /// Action Grid
  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildActionTile(
          icon: Icons.assignment,
          title: 'Attendance',
          subtitle: 'Manage attendance',
          color: Colors.blue,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AttendanceManagementScreen(),
              ),
            );
          },
        ),
        _buildActionTile(
          icon: Icons.person_add,
          title: 'Add Employee',
          subtitle: 'Create new account',
          color: Colors.green,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEmployeeScreen()),
            );
          },
        ),
        _buildActionTile(
          icon: Icons.group,
          title: 'All Employees',
          subtitle: 'View employee list',
          color: Colors.purple,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmployeeListScreen()),
            );
          },
        ),
        _buildActionTile(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'Configure office',
          color: Colors.orange,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  /// Action Tile
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthProvider>().signOut();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
