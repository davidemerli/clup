import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:async/async.dart';

import '../configs.dart';
import '../main.dart';

// Used to avoid connecting too frequently to the ip location API
final _ipLocationCache = new AsyncCache<Position>(const Duration(minutes: 3));

/// Returns the position of the device, either by trying to access the device GPS position
/// or by trying to request a ip geolocalization
Future<Position> determinePosition() async {
  if (kIsWeb) {
    return await ipLocation();
  }

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  // If no geolocalization service, try to get ipLocation
  if (!serviceEnabled) return await ipLocation();

  LocationPermission permission = await Geolocator.checkPermission();

  // Also try to get ipLocation if no permissions for GPS
  if (permission == LocationPermission.deniedForever) return await ipLocation();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return await ipLocation();
    }
  }

  // If all permissions are OK, get position from device GPS
  return await Geolocator.getCurrentPosition();
}

/// Contacts ip geolocator API and returns a Position (lat, long)
Future<Position> ipLocation() async {
  return _ipLocationCache.fetch(() async {
    var response = await dio.get(IP_LOCATION_API_URL);

    if (kDebugMode) print(response);

    var lat = double.parse(response.data['latitude']);
    var long = double.parse(response.data['longitude']);

    return Position(latitude: lat, longitude: long);
  });
}
