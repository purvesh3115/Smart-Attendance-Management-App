import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

enum AttendanceStatus { marked, absent, leave, pending }

@JsonSerializable()
class Attendance {
  final String id;
  final String sessionId;
  final String studentId;
  final String instructorId;
  final AttendanceStatus status;
  final DateTime markedAt;
  final double? latitude;
  final double? longitude;
  final double? distanceFromExpectedLocation;
  final bool isValidLocation;
  final bool isBiometricVerified;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.instructorId,
    required this.status,
    required this.markedAt,
    this.latitude,
    this.longitude,
    this.distanceFromExpectedLocation,
    this.isValidLocation = true,
    this.isBiometricVerified = false,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      _$AttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceToJson(this);

  Attendance copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? instructorId,
    AttendanceStatus? status,
    DateTime? markedAt,
    double? latitude,
    double? longitude,
    double? distanceFromExpectedLocation,
    bool? isValidLocation,
    bool? isBiometricVerified,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      instructorId: instructorId ?? this.instructorId,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceFromExpectedLocation:
          distanceFromExpectedLocation ?? this.distanceFromExpectedLocation,
      isValidLocation: isValidLocation ?? this.isValidLocation,
      isBiometricVerified: isBiometricVerified ?? this.isBiometricVerified,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Attendance(id: $id, sessionId: $sessionId, studentId: $studentId, status: $status)';
}
