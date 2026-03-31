import 'package:json_annotation/json_annotation.dart';
import 'attendance.dart';
import 'session.dart';

part 'report.g.dart';

enum ReportType { attendance, analytics, summary, detailed }

@JsonSerializable()
class AttendanceReport {
  final String id;
  final String generatedBy;
  final ReportType type;
  final DateTime generatedAt;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? sessionId;
  final String? courseCode;
  final String? studentId;
  final String? instructorId;
  final List<ReportRecord> records;
  final ReportSummary summary;
  final String title;
  final String? description;

  AttendanceReport({
    required this.id,
    required this.generatedBy,
    required this.type,
    required this.generatedAt,
    this.fromDate,
    this.toDate,
    this.sessionId,
    this.courseCode,
    this.studentId,
    this.instructorId,
    required this.records,
    required this.summary,
    required this.title,
    this.description,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) =>
      _$AttendanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceReportToJson(this);
}

@JsonSerializable()
class ReportRecord {
  final String studentId;
  final String studentName;
  final String? courseCode;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final double attendancePercentage;
  final DateTime? lastAttendanceDate;
  final List<String> remarks;

  ReportRecord({
    required this.studentId,
    required this.studentName,
    this.courseCode,
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.attendancePercentage,
    this.lastAttendanceDate,
    this.remarks = const [],
  });

  factory ReportRecord.fromJson(Map<String, dynamic> json) =>
      _$ReportRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ReportRecordToJson(this);
}

@JsonSerializable()
class ReportSummary {
  final int totalRecords;
  final double averageAttendance;
  final int totalPresent;
  final int totalAbsent;
  final int totalLeave;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> additionalMetrics;

  ReportSummary({
    required this.totalRecords,
    required this.averageAttendance,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLeave,
    required this.startDate,
    required this.endDate,
    this.additionalMetrics = const {},
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryToJson(this);
}
