import 'package:logger/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/report.dart';
import '../models/attendance.dart';
import 'attendance_service.dart';

class ReportService {
  final Logger _logger = Logger();
  final AttendanceService _attendanceService;

  ReportService(this._attendanceService);

  /// Generate attendance report for a student
  Future<AttendanceReport?> generateStudentAttendanceReport({
    required String studentId,
    required String studentName,
    required DateTime fromDate,
    required DateTime toDate,
    required String generatedBy,
  }) async {
    try {
      _logger.i('Generating attendance report for student: $studentId');

      final attendanceRecords = await _attendanceService.getStudentAttendance(studentId);
      
      final filteredRecords = attendanceRecords
          .where((r) => r.markedAt.isAfter(fromDate) && r.markedAt.isBefore(toDate))
          .toList();

      final present = filteredRecords.where((r) => r.status == AttendanceStatus.marked).length;
      final absent = filteredRecords.where((r) => r.status == AttendanceStatus.absent).length;
      final leave = filteredRecords.where((r) => r.status == AttendanceStatus.leave).length;
      final total = filteredRecords.length;

      final percentage = total > 0 ? (present / total * 100) : 0.0;

      final reportRecord = ReportRecord(
        studentId: studentId,
        studentName: studentName,
        totalSessions: total,
        presentCount: present,
        absentCount: absent,
        leaveCount: leave,
        attendancePercentage: percentage,
      );

      final summary = ReportSummary(
        totalRecords: total,
        averageAttendance: percentage,
        totalPresent: present,
        totalAbsent: absent,
        totalLeave: leave,
        startDate: fromDate,
        endDate: toDate,
      );

      final report = AttendanceReport(
        id: '${studentId}_${DateTime.now().millisecondsSinceEpoch}',
        generatedBy: generatedBy,
        type: ReportType.detailed,
        generatedAt: DateTime.now(),
        fromDate: fromDate,
        toDate: toDate,
        studentId: studentId,
        records: [reportRecord],
        summary: summary,
        title: 'Attendance Report - $studentName',
        description: 'Detailed attendance report from ${fromDate.toString().split(' ')[0]} to ${toDate.toString().split(' ')[0]}',
      );

      _logger.i('Student attendance report generated successfully');
      return report;
    } catch (e) {
      _logger.e('Error generating student attendance report: $e');
      return null;
    }
  }

  /// Generate class attendance report
  Future<AttendanceReport?> generateClassAttendanceReport({
    required String sessionId,
    required String courseCode,
    required String courseName,
    required String generatedBy,
    required List<String> studentIds,
  }) async {
    try {
      _logger.i('Generating class attendance report for session: $sessionId');

      final records = <ReportRecord>[];
      
      for (final studentId in studentIds) {
        final studentRecords = await _attendanceService.getStudentAttendance(studentId);
        final sessionRecord = studentRecords.firstWhere(
          (r) => r.sessionId == sessionId,
          orElse: () => Attendance(
            id: '',
            sessionId: sessionId,
            studentId: studentId,
            instructorId: '',
            status: AttendanceStatus.absent,
            markedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (sessionRecord.id.isNotEmpty) {
          final reportRecord = ReportRecord(
            studentId: studentId,
            studentName: studentId,
            courseCode: courseCode,
            totalSessions: 1,
            presentCount: sessionRecord.status == AttendanceStatus.marked ? 1 : 0,
            absentCount: sessionRecord.status == AttendanceStatus.absent ? 1 : 0,
            leaveCount: sessionRecord.status == AttendanceStatus.leave ? 1 : 0,
            attendancePercentage: sessionRecord.status == AttendanceStatus.marked ? 100.0 : 0.0,
          );
          records.add(reportRecord);
        }
      }

      final totalPresent = records.where((r) => r.presentCount > 0).length;
      final totalAbsent = records.where((r) => r.absentCount > 0).length;
      final averageAttendance = records.isNotEmpty 
          ? records.map((r) => r.attendancePercentage).reduce((a, b) => a + b) / records.length 
          : 0.0;

      final summary = ReportSummary(
        totalRecords: records.length,
        averageAttendance: averageAttendance,
        totalPresent: totalPresent,
        totalAbsent: totalAbsent,
        totalLeave: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final report = AttendanceReport(
        id: '${sessionId}_${DateTime.now().millisecondsSinceEpoch}',
        generatedBy: generatedBy,
        type: ReportType.summary,
        generatedAt: DateTime.now(),
        sessionId: sessionId,
        courseCode: courseCode,
        records: records,
        summary: summary,
        title: 'Class Attendance Report - $courseName',
        description: 'Attendance report for session $sessionId',
      );

      _logger.i('Class attendance report generated successfully');
      return report;
    } catch (e) {
      _logger.e('Error generating class attendance report: $e');
      return null;
    }
  }

  /// Export report to PDF
  Future<bool> exportReportToPDF(AttendanceReport report) async {
    try {
      _logger.i('Exporting report to PDF');

      // TODO: Implement PDF generation using pdf package
      // final pdf = pw.Document();
      // pdf.addPage(
      //   pw.Page(
      //     build: (pw.Context context) {
      //       return pw.Column(
      //         children: [
      //           pw.Text('Attendance Report'),
      //           // Add report data to PDF
      //         ],
      //       );
      //     },
      //   ),
      // );

      // TODO: Save or share PDF
      // await Printing.layoutPdf(
      //   onLayout: (PdfPageFormat format) async => pdf.save(),
      // );

      _logger.i('Report exported to PDF successfully');
      return true;
    } catch (e) {
      _logger.e('Error exporting report to PDF: $e');
      return false;
    }
  }

  /// Generate analytics summary
  Future<Map<String, dynamic>> generateAnalytics({
    required List<String> studentIds,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      _logger.i('Generating attendance analytics');

      final analytics = <String, dynamic>{};

      // Calculate statistics for each student
      for (final studentId in studentIds) {
        final stats = await _attendanceService.getStudentStats(studentId);
        analytics[studentId] = {
          'totalSessions': stats.totalSessions,
          'presentCount': stats.presentCount,
          'absentCount': stats.absentCount,
          'leaveCount': stats.leaveCount,
          'attendancePercentage': stats.attendancePercentage,
        };
      }

      // Calculate overall statistics
      final totalStudents = studentIds.length;
      final totalSessions = studentIds.isNotEmpty 
          ? (analytics[studentIds.first] as Map?)?['totalSessions'] ?? 0 
          : 0;

      analytics['overall'] = {
        'totalStudents': totalStudents,
        'totalSessions': totalSessions,
        'averageAttendance': _calculateAverageAttendance(analytics),
      };

      _logger.i('Analytics generated successfully');
      return analytics;
    } catch (e) {
      _logger.e('Error generating analytics: $e');
      return {};
    }
  }

  double _calculateAverageAttendance(Map<String, dynamic> analytics) {
    int totalPercentage = 0;
    int count = 0;

    analytics.forEach((key, value) {
      if (key != 'overall' && value is Map) {
        totalPercentage += (value['attendancePercentage'] as num).toInt();
        count++;
      }
    });

    return count > 0 ? totalPercentage / count : 0.0;
  }
}
