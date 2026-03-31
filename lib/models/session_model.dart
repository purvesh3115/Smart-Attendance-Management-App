class SessionModel {
  final String id;
  final String instructorId;
  final String instructorName;
  final String subject;
  final String className;
  final DateTime startTime;
  final DateTime expiryTime; // QR valid until this time
  final double? latitude;    // GPS anchor point
  final double? longitude;
  final double radiusMeters; // allowed radius from anchor
  final bool isActive;
  final String qrPayload;    // encoded data in QR

  SessionModel({
    required this.id,
    required this.instructorId,
    required this.instructorName,
    required this.subject,
    required this.className,
    required this.startTime,
    required this.expiryTime,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100.0,
    required this.isActive,
    required this.qrPayload,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  int get remainingSeconds {
    final diff = expiryTime.difference(DateTime.now());
    return diff.isNegative ? 0 : diff.inSeconds;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'instructorId': instructorId,
        'instructorName': instructorName,
        'subject': subject,
        'className': className,
        'startTime': startTime.toIso8601String(),
        'expiryTime': expiryTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'isActive': isActive ? 1 : 0,
        'qrPayload': qrPayload,
      };

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
        id: map['id'],
        instructorId: map['instructorId'],
        instructorName: map['instructorName'],
        subject: map['subject'],
        className: map['className'],
        startTime: DateTime.parse(map['startTime']),
        expiryTime: DateTime.parse(map['expiryTime']),
        latitude: map['latitude'],
        longitude: map['longitude'],
        radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 100.0,
        isActive: map['isActive'] == 1 || map['isActive'] == true,
        qrPayload: map['qrPayload'],
      );
}
