// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wing_tech_task/screens/add_asset_screen.dart';
import 'package:wing_tech_task/screens/asset_list_screen.dart';
import '../controllers/asset_controller.dart';
import 'qr_scanner_screen.dart';
 

class DashboardScreen extends StatelessWidget {
  final AssetController controller = Get.put(AssetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Statistics Cards
            Obx(() => Row(
              children: [
                _buildStatCard(
                  'Total Assets',
                  controller.totalAssets.toString(),
                  Icons.inventory,
                  Colors.blue,
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  'Available',
                  controller.availableAssets.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            )),
            SizedBox(height: 16),
            Obx(() => Row(
              children: [
                _buildStatCard(
                  'Checked Out',
                  controller.checkedOutAssets.toString(),
                  Icons.assignment_turned_in,
                  Colors.orange,
                ),
                SizedBox(width: 16),
                _buildStatCard(
                  'Overdue',
                  controller.overdueAssets.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            )),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    'Scan QR Code',
                    Icons.qr_code_scanner,
                    Colors.blue,
                    () => Get.to(() => QRScannerScreen()),
                  ),
                  _buildActionCard(
                    'Add Asset',
                    Icons.add_box,
                    Colors.green,
                    () => Get.to(() => AddAssetScreen()),
                  ),
                  _buildActionCard(
                    'View All Assets',
                    Icons.list,
                    Colors.purple,
                    () => Get.to(() => AssetListScreen()),
                  ),
                  _buildActionCard(
                    'Reports',
                    Icons.analytics,
                    Colors.teal,
                    () => _showReports(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(title, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReports() {
    // Implement reports functionality
    Get.snackbar('Reports', 'Feature coming soon!');
  }
}
