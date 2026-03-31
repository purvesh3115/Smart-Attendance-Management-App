import 'package:logger/logger.dart';
import '../models/attendance.dart';
import '../models/session.dart';
import 'database_service.dart';

class AttendanceService {
  final Logger _logger = Logger();
  final DatabaseService _databaseService;

  AttendanceService(this._databaseService);

  /// Mark attendance for a student
  Future<bool> markAttendance({
    required String sessionId,
    required String studentId,
    required String instructorId,
    required double? latitude,
    required double? longitude,
    required bool isValidLocation,
    bool isBiometricVerified = false,
    String? remarks,
  }) async {
    try {
      _logger.i('Marking attendance for student: $studentId, session: $sessionId');

      final attendance = Attendance(
        id: '${sessionId}_${studentId}_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        studentId: studentId,
        instructorId: instructorId,
        status: AttendanceStatus.marked,
        markedAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        isValidLocation: isValidLocation,
        isBiometricVerified: isBiometricVerified,
        remarks: remarks,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _databaseService.insertAttendance(attendance);
      
      if (result) {
        _logger.i('Attendance marked successfully');
      } else {
        _logger.w('Failed to mark attendance');
      }

      return result;
    } catch (e) {
      _logger.e('Error marking attendance: $e');
      return false;
    }
  }

  /// Get attendance records for a session
  Future<List<Attendance>> getSessionAttendance(String sessionId) async {
    try {
      _logger.i('Fetching attendance for session: $sessionId');
      return await _databaseService.getAttendanceBySession(sessionId);
    } catch (e) {
      _logger.e('Error fetching session attendance: $e');
      return [];
    }
  }

  /// Get attendance records for a student
  Future<List<Attendance>> getStudentAttendance(String studentId) async {
    try {
      _logger.i('Fetching attendance for student: $studentId');
      return await _databaseService.getAttendanceByStudent(studentId);
    } catch (e) {
      _logger.e('Error fetching student attendance: $e');
      return [];
    }
  }

  /// Get attended sessions for a student
  Future<List<String>> getAttendedSessions(String studentId) async {
    try {
      final records = await getStudentAttendance(studentId);
      return records.where((a) => a.status == AttendanceStatus.marked)
          .map((a) => a.sessionId)
          .toList();
    } catch (e) {
      _logger.e('Error fetching attended sessions: $e');
      return [];
    }
  }

  /// Get attendance statistics for a student
  Future<AttendanceStats> getStudentStats(String studentId) async {
    try {
      final records = await getStudentAttendance(studentId);
      
      final present = records.where((a) => a.status == AttendanceStatus.marked).length;
      final absent = records.where((a) => a.status == AttendanceStatus.absent).length;
      final leave = records.where((a) => a.status == AttendanceStatus.leave).length;
      final total = records.length;

      final percentage = total > 0 ? (present / total * 100) : 0.0;

      return AttendanceStats(
        totalSessions: total,
        presentCount: present,
        absentCount: absent,
        leaveCount: leave,
        attendancePercentage: percentage,
      );
    } catch (e) {
      _logger.e('Error calculating student stats: $e');
      return AttendanceStats.empty();
    }
  }

  /// Check if student already marked attendance for a session
  Future<bool> hasStudentMarkedAttendance({
    required String sessionId,
    required String studentId,
  }) async {
    try {
      final records = await _databaseService.getAttendanceBySessionAndStudent(
        sessionId,
        studentId,
      );
      
      return records.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking attendance status: $e');
      return false;
    }
  }

  /// Update attendance record
  Future<bool> updateAttendance(Attendance attendance) async {
    try {
      _logger.i('Updating attendance: ${attendance.id}');
      return await _databaseService.updateAttendance(attendance);
    } catch (e) {
      _logger.e('Error updating attendance: $e');
      return false;
    }
  }

  /// Get attendance summary for a course
  Future<List<CourseAttendanceSummary>> getCourseAttendanceSummary(
    String courseCode,
  ) async {
    try {
      // TODO: Implement course-level attendance summary
      _logger.d('Fetching attendance summary for course: $courseCode');
      return [];
    } catch (e) {
      _logger.e('Error fetching course attendance summary: $e');
      return [];
    }
  }
}

class AttendanceStats {
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final double attendancePercentage;

  AttendanceStats({
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.attendancePercentage,
  });

  factory AttendanceStats.empty() {
    return AttendanceStats(
      totalSessions: 0,
      presentCount: 0,
      absentCount: 0,
      leaveCount: 0,
      attendancePercentage: 0.0,
    );
  }
}

class CourseAttendanceSummary {
  final String courseCode;
  final String courseName;
  final double averageAttendance;
  final int totalStudents;
  final int totalSessions;

  CourseAttendanceSummary({
    required this.courseCode,
    required this.courseName,
    required this.averageAttendance,
    required this.totalStudents,
    required this.totalSessions,
  });
}
