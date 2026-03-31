import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class GPSService {
  final Logger _logger = Logger();

  static const double _defaultRadius = 100.0; // meters

  /// Check and request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      _logger.i('Requesting location permission');
      
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final isGranted = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      
      _logger.d('Location permission granted: $isGranted');
      return isGranted;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      _logger.i('Fetching current location');
      
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission not granted');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.d('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    }
  }

  /// Validate if user is within allowed GPS radius of session location
  Future<bool> validateLocationProximity({
    required double sessionLatitude,
    required double sessionLongitude,
    double radiusMeters = _defaultRadius,
  }) async {
    try {
      _logger.i('Validating location proximity');
      
      final currentPosition = await getCurrentLocation();
      if (currentPosition == null) {
        _logger.w('Could not fetch current location');
        return false;
      }

      final distance = Geolocator.distanceBetween(
        sessionLatitude,
        sessionLongitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      final isWithinRadius = distance <= radiusMeters;
      
      _logger.d('Distance from session: $distance meters, Within radius: $isWithinRadius');
      return isWithinRadius;
    } catch (e) {
      _logger.e('Error validating location proximity: $e');
      return false;
    }
  }

  /// Get distance between two coordinates in meters
  Future<double> getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      
      _logger.d('Distance calculated: $distance meters');
      return distance;
    } catch (e) {
      _logger.e('Error calculating distance: $e');
      return -1;
    }
  }

  /// Enable location services if disabled
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      _logger.e('Error opening location settings: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      _logger.e('Error checking location service: $e');
      return false;
    }
  }

  /// Stream location updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 0,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
