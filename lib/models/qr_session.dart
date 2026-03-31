import 'package:json_annotation/json_annotation.dart';

part 'qr_session.g.dart';

enum QRCodeStatus { active, expired, used, revoked }

@JsonSerializable()
class QRSession {
  final String id;
  final String sessionId;
  final String instructorId;
  final String qrCodeData;
  final QRCodeStatus status;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final int scansCount;
  final List<String> scannedByStudents;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  QRSession({
    required this.id,
    required this.sessionId,
    required this.instructorId,
    required this.qrCodeData,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    this.scansCount = 0,
    this.scannedByStudents = const [],
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QRSession.fromJson(Map<String, dynamic> json) =>
      _$QRSessionFromJson(json);

  Map<String, dynamic> toJson() => _$QRSessionToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isActive => status == QRCodeStatus.active && !isExpired;

  int get remainingValiditySeconds {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  bool hasStudentScanned(String studentId) =>
      scannedByStudents.contains(studentId);

  QRSession copyWith({
    String? id,
    String? sessionId,
    String? instructorId,
    String? qrCodeData,
    QRCodeStatus? status,
    DateTime? issuedAt,
    DateTime? expiresAt,
    int? scansCount,
    List<String>? scannedByStudents,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QRSession(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      instructorId: instructorId ?? this.instructorId,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      status: status ?? this.status,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      scansCount: scansCount ?? this.scansCount,
      scannedByStudents: scannedByStudents ?? this.scannedByStudents,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'QRSession(id: $id, sessionId: $sessionId, status: $status, isExpired: $isExpired)';
}
