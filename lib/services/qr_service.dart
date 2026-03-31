import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:math';
import '../models/qr_session.dart';

class QRService {
  final Logger _logger = Logger();

  /// Generate QR code data for a session
  String generateQRCode({
    required String sessionId,
    required String instructorId,
  }) {
    try {
      _logger.i('Generating QR code for session: $sessionId');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final randomNum = random.nextInt(10000);
      
      final qrData = {
        'sessionId': sessionId,
        'instructorId': instructorId,
        'timestamp': timestamp,
        'random': randomNum,
      };

      final encodedData = base64Encode(utf8.encode(jsonEncode(qrData)));
      
      _logger.d('QR code generated: $encodedData');
      return encodedData;
    } catch (e) {
      _logger.e('Error generating QR code: $e');
      return '';
    }
  }

  /// Decode and validate QR code data
  Future<Map<String, dynamic>?> decodeQRCode(String qrCodeData) async {
    try {
      _logger.i('Decoding QR code');
      
      final decodedData = utf8.decode(base64Decode(qrCodeData));
      final jsonData = jsonDecode(decodedData) as Map<String, dynamic>;
      
      _logger.d('QR code decoded: $jsonData');
      return jsonData;
    } catch (e) {
      _logger.e('Error decoding QR code: $e');
      return null;
    }
  }

  /// Validate if QR code is not expired
  bool isQRCodeValid(QRSession qrSession) {
    final isValid = qrSession.isActive;
    _logger.d('QR Code validation result: $isValid');
    return isValid;
  }

  /// Get remaining validity time in seconds
  int getRemainingValiditySeconds(QRSession qrSession) {
    return qrSession.remainingValiditySeconds;
  }

  /// Create QR session object
  QRSession createQRSession({
    required String sessionId,
    required String instructorId,
    required DateTime issuedAt,
    required int validityDurationMinutes,
  }) {
    try {
      final qrCodeData = generateQRCode(
        sessionId: sessionId,
        instructorId: instructorId,
      );

      final expiresAt = issuedAt.add(Duration(minutes: validityDurationMinutes));

      return QRSession(
        id: '${sessionId}_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        instructorId: instructorId,
        qrCodeData: qrCodeData,
        status: QRCodeStatus.active,
        issuedAt: issuedAt,
        expiresAt: expiresAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error creating QR session: $e');
      rethrow;
    }
  }

  /// Verify QR code with session ID and instructor ID
  bool verifyQRCode({
    required String? decodedSessionId,
    required String? decodedInstructorId,
    required String expectedSessionId,
    required String expectedInstructorId,
  }) {
    final isValid = decodedSessionId == expectedSessionId &&
        decodedInstructorId == expectedInstructorId;
    
    _logger.d('QR Code verification result: $isValid');
    return isValid;
  }
}
