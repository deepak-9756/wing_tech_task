import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';

class AttendanceReportsScreen extends StatefulWidget {
  @override
  _AttendanceReportsScreenState createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  final FirestoreService firestoreService = Get.find();

  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  String selectedFilter = 'This Month';
  UserModel? selectedEmployee;

  final List<String> filterOptions = [
    'Today',
    'This Week',
    'This Month',
    'Custom Range',
    'Employee Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Reports'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildReportView()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Report Type',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: filterOptions.map((filter) {
              return DropdownMenuItem(
                value: filter,
                child: Text(filter),
              );
            }).toList(),
            value: selectedFilter,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  selectedFilter = value;
                  _updateDateRange();
                  if (value != 'Employee Report') {
                    selectedEmployee = null;
                  }
                });
              }
            },
          ),
          SizedBox(height: 12),
          if (selectedFilter == 'Custom Range')
            Row(
              children: [
                Expanded(child: _dateSelector(true)),
                SizedBox(width: 12),
                Expanded(child: _dateSelector(false)),
              ],
            ),
          if (selectedFilter == 'Employee Report')
            FutureBuilder<List<UserModel>>(
              future: firestoreService.getAllEmployees().first,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                return DropdownButtonFormField<UserModel>(
                  decoration: InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: snapshot.data!
                      .map((e) => DropdownMenuItem<UserModel>(
                            value: e,
                            child: Text('${e.name} (${e.employeeId})'),
                          ))
                      .toList(),
                  value: selectedEmployee,
                  onChanged: (UserModel? value) {
                    setState(() {
                      selectedEmployee = value;
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _dateSelector(bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStart ? 'Start Date' : 'End Date',
          border: OutlineInputBorder(),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(isStart ? startDate : endDate),
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) {
            startDate = endDate;
          }
        }
      });
    }
  }

  Widget _buildReportView() {
    switch (selectedFilter) {
      case 'Today':
        startDate = DateTime.now();
        endDate = DateTime.now();
        return _buildReportList();
      case 'This Week':
        DateTime now = DateTime.now();
        int dayOfWeek = now.weekday;
        startDate = now.subtract(Duration(days: dayOfWeek - 1));
        endDate = now;
        return _buildReportList();
      case 'This Month':
        DateTime now = DateTime.now();
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        return _buildReportList();
      case 'Custom Range':
        return _buildReportList();
      case 'Employee Report':
        if (selectedEmployee == null) {
          return Center(child: Text('Please select an employee'));
        }
        return _buildEmployeeReport();
      default:
        return _buildReportList();
    }
  }

  Widget _buildReportList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: firestoreService.getAttendanceStats(startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData) return Center(child: Text('No data available'));

        Map<String, dynamic> stats = snapshot.data!;
        List<AttendanceModel> attendances = stats['attendances'];

        return Column(
          children: [
            _buildSummaryCards(stats),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: attendances.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text('${attendances[index].employeeName} (${attendances[index].employeeId})'),
                  subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(attendances[index].date)} | Status: ${attendances[index].status}'),
                  trailing: Text(attendances[index].getFormattedWorkingHours()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeReport() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestoreService.getEmployeeAttendanceReport(selectedEmployee!.uid, startDate, endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('No records found'));

        List<Map<String, dynamic>> records = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Check In')),
              DataColumn(label: Text('Check Out')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Working Hours')),
            ],
            rows: records.map((record) {
              return DataRow(cells: [
                DataCell(Text(record['date'])),
                DataCell(Text(record['checkIn'])),
                DataCell(Text(record['checkOut'])),
                DataCell(Text(record['status'].toUpperCase())),
                DataCell(Text(record['workingHours'])),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard('Total Records', stats['totalRecords']),
          _buildSummaryCard('Present', stats['present']),
          _buildSummaryCard('Late', stats['late']),
          _buildSummaryCard('Absent', stats['absent']),
          _buildSummaryCard('Half Day', stats['halfday']),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count) {
    return Card(
      elevation: 2,
      child: Container(
        width: 110,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _updateDateRange() {
    DateTime now = DateTime.now();
    switch (selectedFilter) {
      case 'Today':
        startDate = now;
        endDate = now;
        break;
      case 'This Week':
        int weekDay = now.weekday;
        startDate = now.subtract(Duration(days: weekDay - 1));
        endDate = now;
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      default:
        break;
    }
  }
}
