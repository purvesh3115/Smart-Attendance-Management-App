# Smart Attendance Management App

A modern Flutter-based attendance management system that leverages QR codes, biometric authentication, and GPS validation to streamline attendance tracking at EduTrack Systems.

## Features

### For Instructors
- **Session-based QR Code Generation**: Create time-bound QR codes for each class session
- **Real-time Attendance Monitoring**: View live attendance data during sessions
- **Attendance Records Management**: Access historical attendance records and student data
- **Report Generation**: Generate attendance reports for specific periods or classes

### For Students
- **QR Code Scanning**: Quick attendance marking by scanning instructor-generated QR codes
- **GPS Validation**: Location-based verification to prevent remote attendance fraud
- **Biometric Support**: Optional fingerprint/face recognition for enhanced security
- **Offline Support**: Capture attendance offline with automatic sync when connected
- **Attendance History**: View personal attendance records and statistics

### For Administrators
- **Dashboard Analytics**: Comprehensive attendance analytics and insights
- **User Management**: Manage instructors, students, and admin accounts
- **Report Generation**: Generate institution-wide reports and generate PDFs
- **System Monitoring**: Real-time monitoring of attendance activities
- **Data Validation**: Verify attendance integrity and detect anomalies

## Key Pain Points Addressed

✓ **Proxy Attendance Prevention**: GPS location validation and time-bound sessions
✓ **Data Consistency**: Digital records with automatic synchronization
✓ **Real-time Monitoring**: Live attendance tracking and instant notifications
✓ **Fraud Detection**: Biometric integration and location-based verification
✓ **Delayed Reporting**: Instant report generation with analytics

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── user.dart            # User (Instructor, Student, Admin)
│   ├── attendance.dart       # Attendance records
│   ├── session.dart         # Class sessions
│   ├── qr_session.dart      # QR code session data
│   └── report.dart          # Report generation model
├── services/                 # Business logic & APIs
│   ├── auth_service.dart    # Authentication & authorization
│   ├── qr_service.dart      # QR code generation & validation
│   ├── gps_service.dart     # Location tracking & validation
│   ├── attendance_service.dart # Attendance management
│   ├── database_service.dart  # Local database operations
│   ├── sync_service.dart    # Offline sync mechanism
│   ├── report_service.dart  # Report generation
│   └── biometric_service.dart # Biometric authentication
├── screens/
│   ├── auth/                # Login, registration screens
│   ├── instructor/          # Instructor-specific screens
│   │   ├── home_screen.dart
│   │   ├── qr_generator_screen.dart
│   │   ├── attendance_list_screen.dart
│   │   └── reports_screen.dart
│   ├── student/             # Student-specific screens
│   │   ├── home_screen.dart
│   │   ├── qr_scanner_screen.dart
│   │   ├── attendance_history_screen.dart
│   │   └── profile_screen.dart
│   └── admin/               # Admin-specific screens
│       ├── dashboard_screen.dart
│       ├── analytics_screen.dart
│       ├── user_management_screen.dart
│       └── reports_screen.dart
├── widgets/                 # Reusable UI components
│   ├── attendance_card.dart
│   ├── qr_code_display.dart
│   ├── location_indicator.dart
│   └── attendance_chart.dart
└── utils/                   # Utility functions
    ├── constants.dart       # App constants
    ├── validators.dart      # Input validation
    ├── logger.dart          # Logging utility
    └── encryption.dart      # Data encryption

assets/
├── images/
├── icons/
├── animations/
└── fonts/

android/                      # Android-specific configuration
ios/                         # iOS-specific configuration
```

## Technology Stack

### Frontend
- **Flutter 3.0+**: Cross-platform mobile framework
- **Provider/Riverpod**: State management
- **Material Design 3**: UI design system

### Backend Services
- **REST API**: For server synchronization
- **Firebase/Custom Server**: Cloud backend (configurable)

### Database
- **SQLite**: Local data storage
- **Hive**: Lightweight key-value storage for offline data

### Security
- **Local Authentication**: Biometric support (fingerprint/face)
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **End-to-end encryption**: For attendance data

### Location & QR
- **Geolocator**: GPS location services
- **Mobile Scanner**: QR code scanning
- **QR Flutter**: QR code generation

### Analytics & Reporting
- **FL Chart**: Beautiful charts and graphs
- **PDF**: PDF report generation

## Installation & Setup

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Dart SDK (v3.0 or higher)
- Android Studio / Xcode (for mobile deployment)
- Device or emulator running Android/iOS

### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_attendance_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure platform-specific permissions**

   **For Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.USE_BIOMETRIC" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

   **For iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to validate attendance</string>
   <key>NSCameraUsageDescription</key>
   <string>Camera access needed to scan QR codes</string>
   <key>NSFaceIDUsageDescription</key>
   <string>Face ID needed for biometric authentication</string>
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Environment Variables
Create a `.env` file in the project root:
```
API_BASE_URL=https://your-api-endpoint.com
GPS_RADIUS=100  # Meters within which attendance is valid
QR_VALIDITY_DURATION=5  # Minutes
MAX_SYNC_RETRIES=3
```

### Database Initialization
The app automatically initializes SQLite and Hive databases on first launch.

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout
- `POST /api/auth/refresh-token` - Refresh auth token

### Attendance
- `POST /api/attendance/mark` - Mark attendance
- `GET /api/attendance/records/:studentId` - Get student attendance
- `GET /api/attendance/session/:sessionId` - Get session attendance
- `POST /api/attendance/sync` - Sync offline records

### Sessions
- `POST /api/sessions/create` - Create new session (Instructor)
- `GET /api/sessions/active` - Get active sessions
- `GET /api/sessions/:sessionId` - Get session details

### QR Codes
- `POST /api/qr/generate` - Generate QR code
- `POST /api/qr/validate` - Validate QR code

### Admin
- `GET /api/admin/analytics` - Get analytics data
- `GET /api/admin/reports` - Generate reports
- `GET /api/admin/users` - Get all users

## Usage Examples

### For Instructors
1. Log in with instructor credentials
2. Create a new session for the class
3. Generate a QR code (valid for 5 minutes)
4. Students scan the QR code to mark attendance
5. View real-time attendance list
6. Generate reports at the end of the session

### For Students
1. Log in with student credentials
2. Check active sessions from courses
3. Scan instructor-provided QR code
4. Confirm location (within GPS radius)
5. Submit attendance
6. View personal attendance history

### For Administrators
1. Access dashboard to view system analytics
2. Monitor attendance patterns and anomalies
3. Manage user accounts and permissions
4. Generate institution-wide reports
5. Review system logs and activities

## Security Considerations

1. **Biometric Authentication**: Optional additional security layer
2. **GPS Validation**: Prevents remote attendance fraud
3. **Time-bound Sessions**: QR codes are valid only during specified time windows
4. **Encryption**: Attendance data is encrypted in local storage
5. **Token-based Auth**: JWT tokens for API requests
6. **Secure Storage**: Sensitive data stored in platform-secure storage

## Offline Support

- Attendance records are captured locally when offline
- Automatic sync when network connection is restored
- Conflict resolution for duplicate records
- Retry mechanism for failed sync attempts

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Generate coverage report
flutter test --coverage
```

## Troubleshooting

### GPS Not Working
- Check location permissions in device settings
- Ensure GPS is enabled on device
- Verify GPS radius is configured correctly

### QR Code Scanning Issues
- Check camera permissions
- Ensure camera is not in use by other apps
- Try adjusting lighting conditions

### Offline Sync Issues
- Check internet connectivity
- Review sync logs in the app
- Manually trigger sync from settings

## Contributing

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit changes (`git commit -m 'Add AmazingFeature'`)
3. Push to branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Contact & Support

For issues, questions, or suggestions, please contact the EduTrack Systems development team.

## Changelog

### Version 1.0.0
- Initial release
- QR code-based attendance
- GPS validation
- Biometric authentication
- Admin dashboard with analytics
- Offline sync capability
- Report generation
#   S m a r t - A t t e n d a n c e - M a n a g e m e n t - A p p  
 