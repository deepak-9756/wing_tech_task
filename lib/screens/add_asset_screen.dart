// lib/screens/add_asset_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wing_tech_task/models/assets_model.dart';
import 'dart:math';
import '../controllers/asset_controller.dart';
 
class AddAssetScreen extends StatefulWidget {
  @override
  _AddAssetScreenState createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final AssetController controller = Get.find<AssetController>();
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  // Predefined Categories
  final List<String> categories = [
    'Laptop',
    'Projector',
    'Mobile Device',
    'Camera',
    'Tablet',
    'Monitor',
    'Printer',
    'Audio Equipment',
    'Other Equipment',
  ];
  
  String? selectedCategory;
  String generatedQRCode = '';
  bool showQRPreview = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Asset'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () => _generateQRCode(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asset Name Field
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Asset Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Asset Name *',
                          hintText: 'e.g., MacBook Pro M1',
                          prefixIcon: Icon(Icons.inventory),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Asset name is required';
                          }
                          if (value.length < 3) {
                            return 'Asset name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            categoryController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Description Field
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Additional details about the asset...',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // QR Code Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            'QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      if (generatedQRCode.isEmpty) ...[
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'QR Code will be generated automatically',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // QR Code Preview
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: QrImageView(
                              data: generatedQRCode,
                              version: QrVersions.auto,
                              size: 150.0,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'QR Code: $generatedQRCode',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 16),
                      
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _generateQRCode(),
                          icon: Icon(Icons.refresh),
                          label: Text(generatedQRCode.isEmpty ? 'Generate QR Code' : 'Regenerate QR Code'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveAsset(),
                      child: Text('Save Asset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateQRCode() {
    // Generate unique QR code using timestamp and random number
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    final qrCode = 'ASSET_${timestamp}_$random';
    
    setState(() {
      generatedQRCode = qrCode;
      showQRPreview = true;
    });
    
    Get.snackbar(
      'QR Code Generated',
      'Unique QR code created for this asset',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }

  void _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    if (generatedQRCode.isEmpty) {
      Get.snackbar(
        'QR Code Required',
        'Please generate a QR code for this asset',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    try {
      // Show loading dialog
      Get.dialog(
        Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Saving asset...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Create new asset
      final newAsset = Asset(
        id: generatedQRCode,
        name: nameController.text.trim(),
        category: selectedCategory!,
        qrCode: generatedQRCode,
        isAvailable: true,
        createdAt: DateTime.now(),
        createdBy: 'Current User', // Replace with actual user
      );

      // Save to database
      await controller.addAsset(newAsset);

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Asset "${nameController.text}" added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: Duration(seconds: 3),
      );

      // Go back to dashboard
      Get.back();

    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to save asset. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
