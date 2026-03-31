import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';
import '../models/attendance.dart';

class SyncService {
  final Logger _logger = Logger();
  final DatabaseService _databaseService;
  final Connectivity _connectivity = Connectivity();

  int _syncRetries = 0;
  static const int _maxRetries = 3;

  SyncService(this._databaseService);

  /// Initialize sync service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing SyncService');
      _connectivity.onConnectivityChanged.listen((result) {
        if (result != ConnectivityResult.none) {
          _logger.i('Network connectivity restored, attempting sync');
          syncOfflineData();
        }
      });
    } catch (e) {
      _logger.e('Error initializing SyncService: $e');
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  /// Sync offline attendance data
  Future<bool> syncOfflineData() async {
    try {
      _logger.i('Starting offline data sync');
      
      final isConnected = await isConnected();
      if (!isConnected) {
        _logger.w('No internet connection available for sync');
        return false;
      }

      // TODO: Fetch pending attendance records from database
      // final pendingRecords = await _databaseService.getPendingAttendance();
      
      // TODO: Send records to server
      // for (final record in pendingRecords) {
      //   final success = await _uploadAttendanceRecord(record);
      //   if (success) {
      //     await _databaseService.markAttendanceAsSynced(record.id);
      //   }
      // }

      _logger.i('Offline data sync completed successfully');
      return true;
    } catch (e) {
      _logger.e('Error during offline data sync: $e');
      
      if (_syncRetries < _maxRetries) {
        _syncRetries++;
        _logger.i('Retrying sync (attempt $_syncRetries/$_maxRetries)');
        await Future.delayed(const Duration(seconds: 5));
        return await syncOfflineData();
      }
      
      return false;
    }
  }

  /// Upload single attendance record to server
  Future<bool> _uploadAttendanceRecord(Attendance attendance) async {
    try {
      _logger.d('Uploading attendance record: ${attendance.id}');
      
      // TODO: Implement API call to upload attendance
      // final response = await _apiService.post(
      //   '/attendance/sync',
      //   attendance.toJson(),
      // );

      return true;
    } catch (e) {
      _logger.e('Error uploading attendance record: $e');
      return false;
    }
  }

  /// Download latest data from server
  Future<bool> syncDownstream() async {
    try {
      _logger.i('Starting downstream sync');
      
      final isConnected = await isConnected();
      if (!isConnected) {
        _logger.w('No internet connection for downstream sync');
        return false;
      }

      // TODO: Fetch latest sessions, users, etc. from server
      // final sessions = await _apiService.get('/sessions');
      // final users = await _apiService.get('/users');
      
      // TODO: Update local database with fetched data
      
      _logger.i('Downstream sync completed successfully');
      return true;
    } catch (e) {
      _logger.e('Error during downstream sync: $e');
      return false;
    }
  }

  /// Perform full sync (upstream and downstream)
  Future<bool> fullSync() async {
    try {
      _logger.i('Starting full sync');
      
      final upstreamSuccess = await syncOfflineData();
      final downstreamSuccess = await syncDownstream();

      return upstreamSuccess && downstreamSuccess;
    } catch (e) {
      _logger.e('Error during full sync: $e');
      return false;
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    try {
      final isConnected = await isConnected();
      
      // TODO: Get pending records count
      // final pendingCount = await _databaseService.getPendingAttendanceCount();
      
      return SyncStatus(
        isConnected: isConnected,
        lastSyncTime: DateTime.now(),
        pendingRecords: 0,
      );
    } catch (e) {
      _logger.e('Error getting sync status: $e');
      return SyncStatus(
        isConnected: false,
        lastSyncTime: null,
        pendingRecords: 0,
      );
    }
  }

  /// Reset sync retries
  void resetRetries() {
    _syncRetries = 0;
  }
}

class SyncStatus {
  final bool isConnected;
  final DateTime? lastSyncTime;
  final int pendingRecords;

  SyncStatus({
    required this.isConnected,
    required this.lastSyncTime,
    required this.pendingRecords,
  });

  bool get hasPendingData => pendingRecords > 0;
}
