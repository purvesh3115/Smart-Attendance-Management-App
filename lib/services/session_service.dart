import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/attendance_record.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'location_service.dart';

class SessionService {
  static const _uuid = Uuid();

  /// Create a new attendance session and generate QR payload
  static Future<SessionModel> createSession({
    required UserModel instructor,
    required String subject,
    required String className,
    required int durationMinutes,
    bool useGps = true,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();
    final expiry = now.add(Duration(minutes: durationMinutes));

    try {
      double? lat, lng;
      if (useGps) {
        // Reduced timeout and catch for GPS fetching
        try {
          final pos = await LocationService.getCurrentPosition();
          lat = pos?.latitude;
          lng = pos?.longitude;
        } catch (e) {
          print("GPS fetch error during session creation: $e");
          // Continue without GPS if it fails
        }
      }

      final payload = jsonEncode({
        'sessionId': sessionId,
        'subject': subject,
        'className': className,
        'expiry': expiry.toIso8601String(),
        'lat': lat,
        'lng': lng,
        'radius': 100.0,
        'token': _simpleToken(sessionId, expiry.toIso8601String()),
      });

      final session = SessionModel(
        id: sessionId,
        instructorId: instructor.id,
        instructorName: instructor.name,
        subject: subject,
        className: className,
        startTime: now,
        expiryTime: expiry,
        latitude: lat,
        longitude: lng,
        radiusMeters: 100.0,
        isActive: true,
        qrPayload: payload,
      );

      await DatabaseService.instance.insertSession(session);
      return session;
    } catch (e) {
      print("Error in createSession: $e");
      rethrow; // Propagate to UI for Snackbar
    }
  }

  /// Validate and mark attendance from scanned QR
  static Future<AttendanceResult> markAttendance({
    required String qrPayload,
    required UserModel student,
  }) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(qrPayload);
    } catch (_) {
      return AttendanceResult.failure('Invalid QR code format.');
    }

    // 1. Validate token integrity
    final sessionId = data['sessionId'] as String?;
    final expiryStr = data['expiry'] as String?;
    if (sessionId == null || expiryStr == null) {
      return AttendanceResult.failure('Malformed QR code.');
    }
    final expectedToken = _simpleToken(sessionId, expiryStr);
    if (data['token'] != expectedToken) {
      return AttendanceResult.failure('QR code integrity check failed.');
    }

    // 2. Check expiry
    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      return AttendanceResult.failure('QR code has expired. Ask instructor to generate a new one.');
    }

    // 3. Check duplicate
    final db = DatabaseService.instance;
    final alreadyMarked = await db.hasStudentMarkedSession(sessionId, student.id);
    if (alreadyMarked) {
      return AttendanceResult.failure('Attendance already marked for this session.');
    }

    // 4. GPS validation
    final sessionLat = data['lat'] as double?;
    final sessionLng = data['lng'] as double?;
    if (sessionLat != null && sessionLng != null) {
      final pos = await LocationService.getCurrentPosition();
      if (pos == null) {
        return AttendanceResult.failure('Could not determine your location. Enable GPS.');
      }
      final radius = (data['radius'] as num?)?.toDouble() ?? 100.0;
      final distance = LocationService.distanceInMeters(
          pos.latitude, pos.longitude, sessionLat, sessionLng);
      if (distance > radius) {
        return AttendanceResult.failure(
            'You are ${distance.toStringAsFixed(0)}m away from the classroom. Must be within ${radius.toStringAsFixed(0)}m.');
      }
    }

    // 5. Fetch session for metadata
    final session = await db.getSessionById(sessionId);
    if (session == null) {
      return AttendanceResult.failure('Session not found in records.');
    }

    // 6. Record attendance
    final pos = await LocationService.getCurrentPosition();
    final record = AttendanceRecord(
      id: _uuid.v4(),
      sessionId: sessionId,
      studentId: student.id,
      studentName: student.name,
      subject: data['subject'] as String? ?? session.subject,
      className: data['className'] as String? ?? session.className,
      markedAt: DateTime.now(),
      status: AttendanceStatus.present,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      isSynced: true,
    );

    await db.insertAttendance(record);
    return AttendanceResult.success(record, session);
  }

  static String _simpleToken(String sessionId, String expiry) {
    // Simple deterministic token
    final raw = '$sessionId|$expiry|edutrack_secret';
    int hash = 0;
    for (final c in raw.codeUnits) {
      hash = ((hash << 5) - hash + c) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class AttendanceResult {
  final bool success;
  final String? errorMessage;
  final AttendanceRecord? record;
  final SessionModel? session;

  AttendanceResult.success(this.record, this.session)
      : success = true,
        errorMessage = null;

  AttendanceResult.failure(this.errorMessage)
      : success = false,
        record = null,
        session = null;
}
