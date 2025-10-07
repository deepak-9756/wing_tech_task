import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class LocationService extends GetxController {

  Future<bool> requestLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission == PermissionStatus.denied) {
      permission = await Permission.locationWhenInUse.request();
    }
    if (permission == PermissionStatus.permanentlyDenied) {
      Get.dialog(
        AlertDialog(
          title: Text('Permission Required'),
          content: Text('Location permission is required for attendance marking. Please enable it in settings.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(onPressed: () {
              Get.back();
              openAppSettings();
            }, child: Text('Settings')),
          ],
        ),
      );
      return false;
    }
    return permission == PermissionStatus.granted;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Location Disabled', 'Please enable location services');
        return null;
      }
      
      bool permit = await requestLocationPermission();
      if (!permit) return null;
      
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get location: $e');
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool isWithinOfficeRadius(Position currentPos, double officeLat, double officeLng, double radius) {
    double dist = calculateDistance(currentPos.latitude, currentPos.longitude, officeLat, officeLng);
    return dist <= radius;
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }
}
