enum AttendanceStatus { present, absent, late }

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String subject;
  final String className;
  final DateTime markedAt;
  final AttendanceStatus status;
  final double? latitude;
  final double? longitude;
  final bool isSynced; // for offline sync tracking

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.className,
    required this.markedAt,
    required this.status,
    this.latitude,
    this.longitude,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionId': sessionId,
        'studentId': studentId,
        'studentName': studentName,
        'subject': subject,
        'className': className,
        'markedAt': markedAt.toIso8601String(),
        'status': status.name,
        'latitude': latitude,
        'longitude': longitude,
        'isSynced': isSynced ? 1 : 0,
      };

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) => AttendanceRecord(
        id: map['id'],
        sessionId: map['sessionId'],
        studentId: map['studentId'],
        studentName: map['studentName'],
        subject: map['subject'],
        className: map['className'],
        markedAt: DateTime.parse(map['markedAt']),
        status: AttendanceStatus.values.firstWhere((e) => e.name == map['status']),
        latitude: map['latitude'],
        longitude: map['longitude'],
        isSynced: map['isSynced'] == 1 || map['isSynced'] == true,
      );
}
