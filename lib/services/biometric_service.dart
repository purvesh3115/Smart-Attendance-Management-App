import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger();

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      _logger.i('Checking biometric availability');
      
      final isBiometricSupported = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      _logger.d('Biometric available: $isBiometricSupported, Device supported: $isDeviceSupported');
      return isBiometricSupported;
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      _logger.i('Fetching available biometric types');
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      _logger.e('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate() async {
    try {
      _logger.i('Attempting biometric authentication');
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.w('Biometric not available on this device');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to mark attendance',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      _logger.d('Biometric authentication result: $isAuthenticated');
      return isAuthenticated;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Authenticate with custom message
  Future<bool> authenticateWithMessage(String message) async {
    try {
      _logger.i('Attempting biometric authentication with custom message');
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.w('Biometric not available on this device');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Check if device has enrolled biometrics
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final biometrics = await getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking enrolled biometrics: $e');
      return false;
    }
  }
}
