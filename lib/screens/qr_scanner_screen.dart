// screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:wing_tech_task/models/assets_model.dart';
import '../controllers/asset_controller.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final AssetController controller = Get.find<AssetController>();
  MobileScannerController scannerController = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Asset QR Code'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // MobileScanner(
          //   controller: scannerController,
            
          //   onDetect: (barcode, args) {
          //     if (isScanning && barcode.rawValue != null) {
          //       isScanning = false;
          //       _handleQRCode(barcode.rawValue!);
          //     }
          //   },
          // ),
          // Scanning overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCode(String qrCode) async {
    try {
      final asset = await controller.getAssetByQR(qrCode);
      if (asset != null) {
        Get.back();
        _showAssetDialog(asset);
      } else {
        Get.snackbar(
          'Asset Not Found',
          'No asset found with this QR code',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => isScanning = true);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch asset details',
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => isScanning = true);
    }
  }

  void _showAssetDialog(Asset asset) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                asset.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Category: ${asset.category}'),
              Text('Status: ${asset.isAvailable ? "Available" : "Checked Out"}'),
              if (!asset.isAvailable) ...[
                Text('Assigned to: ${asset.assignedTo}'),
               // Text('Due: ${DateFormat('dd/MM/yyyy').format(asset.expectedReturnDate!)}'),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (asset.isAvailable)
                    ElevatedButton(
                      onPressed: () => _checkOutAsset(asset),
                      child: Text('Check Out'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _checkInAsset(asset),
                      child: Text('Check In'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkOutAsset(Asset asset) {
    // Show check-out form
    Get.back();
    Get.dialog(_buildCheckOutDialog(asset));
  }

  void _checkInAsset(Asset asset) {
    controller.checkInAsset(asset.id);
    Get.back();
    Get.snackbar('Success', 'Asset checked in successfully');
  }

  Widget _buildCheckOutDialog(Asset asset) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    DateTime expectedReturn = DateTime.now().add(Duration(days: 7));

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Check Out Asset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Employee Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Employee Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ListTile(
              title: Text('Expected Return Date'),
              //subtitle: Text(DateFormat('dd/MM/yyyy').format(expectedReturn)),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: expectedReturn,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  expectedReturn = date;
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                      controller.checkOutAsset(
                        asset.id,
                        nameController.text,
                        emailController.text,
                        expectedReturn,
                      );
                      Get.back();
                      Get.snackbar('Success', 'Asset checked out successfully');
                    }
                  },
                  child: Text('Confirm'),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}
