// lib/screens/asset_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wing_tech_task/models/assets_model.dart';
import '../controllers/asset_controller.dart';
 
class AssetListScreen extends StatelessWidget {
  final AssetController controller = Get.find<AssetController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Assets'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Obx(() => Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatChip('Total', controller.totalAssets.toString(), Colors.blue),
                SizedBox(width: 8),
                _buildStatChip('Available', controller.availableAssets.toString(), Colors.green),
                SizedBox(width: 8),
                _buildStatChip('Checked Out', controller.checkedOutAssets.toString(), Colors.orange),
              ],
            ),
          )),
          
          // Assets List
          Expanded(
            child: Obx(() {
              if (controller.assets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No assets found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.assets.length,
                itemBuilder: (context, index) {
                  final asset = controller.assets[index];
                  return _buildAssetCard(asset);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: asset.isAvailable ? Colors.green : Colors.orange,
          child: Icon(
            _getCategoryIcon(asset.category),
            color: Colors.white,
          ),
        ),
        title: Text(
          asset.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${asset.category}'),
            Text('QR: ${asset.qrCode}'),
            if (!asset.isAvailable) ...[
              Text('Assigned to: ${asset.assignedTo}'),
              Text(
                'Due: ${DateFormat('dd/MM/yyyy').format(asset.expectedReturnDate!)}',
                style: TextStyle(
                  color: asset.expectedReturnDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: asset.isAvailable ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                asset.isAvailable ? 'Available' : 'Checked Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showAssetDetails(asset),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop;
      case 'projector':
        return Icons.videocam;
      case 'mobile device':
        return Icons.phone_android;
      case 'camera':
        return Icons.camera_alt;
      case 'tablet':
        return Icons.tablet;
      case 'monitor':
        return Icons.monitor;
      case 'printer':
        return Icons.print;
      case 'audio equipment':
        return Icons.headphones;
      default:
        return Icons.inventory;
    }
  }

  void _showAssetDetails(Asset asset) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                asset.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Category', asset.category),
              _buildDetailRow('QR Code', asset.qrCode),
              _buildDetailRow('Status', asset.isAvailable ? 'Available' : 'Checked Out'),
              if (!asset.isAvailable) ...[
                _buildDetailRow('Assigned To', asset.assignedTo ?? 'Unknown'),
                _buildDetailRow('Email', asset.assignedEmail ?? 'Unknown'),
                _buildDetailRow(
                  'Due Date',
                  DateFormat('dd/MM/yyyy').format(asset.expectedReturnDate!),
                ),
              ],
              _buildDetailRow(
                'Created',
                DateFormat('dd/MM/yyyy').format(asset.createdAt),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    // Implement filter functionality
    Get.snackbar('Filter', 'Filter options coming soon!');
  }
}
