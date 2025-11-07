import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GPSService {
  static Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address = '${place.locality}, ${place.postalCode}';
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'address': address,
        'altitude': position.altitude,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static bool isWithinGeofence(
    double currentLat,
    double currentLon,
    double officeLat,
    double officeLon,
    double radiusInMeters,
  ) {
    final distance = calculateDistance(
      currentLat,
      currentLon,
      officeLat,
      officeLon,
    );
    return distance <= radiusInMeters;
  }
}
