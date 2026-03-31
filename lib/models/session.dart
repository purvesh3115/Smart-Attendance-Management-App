import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

enum SessionStatus { scheduled, active, completed, cancelled }

@JsonSerializable()
class Session {
  final String id;
  final String courseId;
  final String instructorId;
  final String courseName;
  final String courseCode;
  final String? batch;
  final SessionStatus status;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? gpsRadiusMeters;
  final int expectedStudents;
  final int? presentCount;
  final int? absentCount;
  final int? totalMarked;
  final String? notes;
  final bool qrGenerationAllowed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.courseId,
    required this.instructorId,
    required this.courseName,
    required this.courseCode,
    this.batch,
    required this.status,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.actualStartTime,
    this.actualEndTime,
    this.location,
    this.latitude,
    this.longitude,
    this.gpsRadiusMeters = 100,
    required this.expectedStudents,
    this.presentCount,
    this.absentCount,
    this.totalMarked,
    this.notes,
    this.qrGenerationAllowed = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  bool get isActive => status == SessionStatus.active;

  bool get isScheduled => status == SessionStatus.scheduled;

  int get attendancePercentage {
    if (expectedStudents == 0) return 0;
    if (totalMarked == null) return 0;
    return ((totalMarked! / expectedStudents) * 100).toInt();
  }

  Session copyWith({
    String? id,
    String? courseId,
    String? instructorId,
    String? courseName,
    String? courseCode,
    String? batch,
    SessionStatus? status,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    String? location,
    double? latitude,
    double? longitude,
    double? gpsRadiusMeters,
    int? expectedStudents,
    int? presentCount,
    int? absentCount,
    int? totalMarked,
    String? notes,
    bool? qrGenerationAllowed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      instructorId: instructorId ?? this.instructorId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      batch: batch ?? this.batch,
      status: status ?? this.status,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsRadiusMeters: gpsRadiusMeters ?? this.gpsRadiusMeters,
      expectedStudents: expectedStudents ?? this.expectedStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      totalMarked: totalMarked ?? this.totalMarked,
      notes: notes ?? this.notes,
      qrGenerationAllowed: qrGenerationAllowed ?? this.qrGenerationAllowed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Session(id: $id, courseCode: $courseCode, status: $status)';
}
