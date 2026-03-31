import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFC7D2FE);

  // Secondary colors
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  static const Color secondaryLight = Color(0xD5EDFA);

  // Status colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutral colors
  static const Color darkGrey = Color(0xFF1F2937);
  static const Color mediumGrey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color veryLightGrey = Color(0xFFFAFAFA);

  // Background colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
}

class AppDimensions {
  // Padding and margin
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;

  // Card radius
  static const double cardRadius = 12.0;
}

class AppTypography {
  // Text styles
  static const TextStyle headingXLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGrey,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrey,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGrey,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.mediumGrey,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGrey,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.mediumGrey,
  );
}

class AppStrings {
  // App
  static const String appName = 'Smart Attendance';
  static const String appVersion = '1.0.0';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String phoneNumber = 'Phone Number';

  // Attendance
  static const String markAttendance = 'Mark Attendance';
  static const String scanQR = 'Scan QR Code';
  static const String generatedQR = 'Generate QR Code';
  static const String attendance = 'Attendance';
  static const String attendanceRecord = 'Attendance Record';
  static const String attendanceHistory = 'Attendance History';
  static const String present = 'Present';
  static const String absent = 'Absent';
  static const String leave = 'Leave';

  // Session
  static const String session = 'Session';
  static const String sessions = 'Sessions';
  static const String startSession = 'Start Session';
  static const String endSession = 'End Session';
  static const String activeSession = 'Active Session';
  static const String pastSessions = 'Past Sessions';

  // Location
  static const String location = 'Location';
  static const String gps = 'GPS';
  static const String validLocation = 'Valid Location';
  static const String invalidLocation = 'Invalid Location';
  static const String enableLocation = 'Enable Location';

  // Biometric
  static const String biometric = 'Biometric';
  static const String fingerprint = 'Fingerprint';
  static const String faceId = 'Face ID';
  static const String biometricAuthentication = 'Biometric Authentication';

  // Reports
  static const String report = 'Report';
  static const String reports = 'Reports';
  static const String generateReport = 'Generate Report';
  static const String exportPDF = 'Export to PDF';
  static const String downloadReport = 'Download Report';

  // Admin
  static const String dashboard = 'Dashboard';
  static const String analytics = 'Analytics';
  static const String userManagement = 'User Management';
  static const String systemSettings = 'System Settings';

  // Buttons
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String ok = 'OK';
  static const String close = 'Close';

  // Messages
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Information';
  static const String noData = 'No Data Available';
  static const String loading = 'Loading...';
  static const String tryAgain = 'Try Again';
}

// Time constants
class AppTimeouts {
  static const Duration qrValidityDuration = Duration(minutes: 5);
  static const Duration sessionCheckInterval = Duration(seconds: 30);
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration apiTimeout = Duration(seconds: 30);
}

// GPS Constants
class GPSConstants {
  static const double defaultRadius = 100.0; // meters
  static const double maxAllowedRadius = 500.0; // meters
  static const int locationAccuracyThreshold = 20; // meters
}
