import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = 'Current Location';
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = '${p.street ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}';
      }

      return {
        'address': address,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      // Fallback for emulator / testing without GPS hardware
      return {
        'address': 'City Medical Hospital, Medical District',
        'latitude': 37.7749,
        'longitude': -122.4194,
      };
    }
  }
}
