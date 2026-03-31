import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/attendance_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        role TEXT NOT NULL,
        department TEXT,
        enrollmentId TEXT,
        employeeId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        instructorId TEXT NOT NULL,
        instructorName TEXT NOT NULL,
        subject TEXT NOT NULL,
        className TEXT NOT NULL,
        startTime TEXT NOT NULL,
        expiryTime TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        radiusMeters REAL DEFAULT 100.0,
        isActive INTEGER DEFAULT 1,
        qrPayload TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        subject TEXT NOT NULL,
        className TEXT NOT NULL,
        markedAt TEXT NOT NULL,
        status TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  // ──────────── USER METHODS ────────────
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final db = await database;
    final rows = await db.query('users', where: 'role = ?', whereArgs: [role.name]);
    return rows.map(UserModel.fromMap).toList();
  }

  // ──────────── SESSION METHODS ────────────
  Future<void> insertSession(SessionModel session) async {
    final db = await database;
    await db.insert('sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SessionModel>> getAllSessions() async {
    final db = await database;
    final rows = await db.query('sessions', orderBy: 'startTime DESC');
    return rows.map(SessionModel.fromMap).toList();
  }

  Future<List<SessionModel>> getSessionsByInstructor(String instructorId) async {
    final db = await database;
    final rows = await db.query('sessions',
        where: 'instructorId = ?', whereArgs: [instructorId], orderBy: 'startTime DESC');
    return rows.map(SessionModel.fromMap).toList();
  }

  Future<SessionModel?> getSessionById(String id) async {
    final db = await database;
    final rows = await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return SessionModel.fromMap(rows.first);
  }

  Future<void> deactivateSession(String sessionId) async {
    final db = await database;
    await db.update('sessions', {'isActive': 0},
        where: 'id = ?', whereArgs: [sessionId]);
  }

  // ──────────── ATTENDANCE METHODS ────────────
  Future<void> insertAttendance(AttendanceRecord record) async {
    final db = await database;
    await db.insert('attendance', record.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AttendanceRecord>> getAttendanceBySession(String sessionId) async {
    final db = await database;
    final rows = await db.query('attendance', where: 'sessionId = ?', whereArgs: [sessionId]);
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceByStudent(String studentId) async {
    final db = await database;
    final rows = await db.query('attendance',
        where: 'studentId = ?', whereArgs: [studentId], orderBy: 'markedAt DESC');
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<List<AttendanceRecord>> getAllAttendance() async {
    final db = await database;
    final rows = await db.query('attendance', orderBy: 'markedAt DESC');
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<bool> hasStudentMarkedSession(String sessionId, String studentId) async {
    final db = await database;
    final rows = await db.query('attendance',
        where: 'sessionId = ? AND studentId = ?', whereArgs: [sessionId, studentId]);
    return rows.isNotEmpty;
  }

  Future<Map<String, int>> getAttendanceSummaryBySubject(String studentId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT subject, COUNT(*) as total,
             SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) as present
      FROM attendance
      WHERE studentId = ?
      GROUP BY subject
    ''', [studentId]);

    final Map<String, int> result = {};
    for (final row in rows) {
      result['${row['subject']}_total'] = (row['total'] as int?) ?? 0;
      result['${row['subject']}_present'] = (row['present'] as int?) ?? 0;
    }
    return result;
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;
    final totalStudents = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM users WHERE role = "student"')) ?? 0;
    final totalSessions = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM sessions')) ?? 0;
    final totalRecords = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM attendance')) ?? 0;
    final presentCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM attendance WHERE status = "present"')) ?? 0;

    return {
      'totalStudents': totalStudents,
      'totalSessions': totalSessions,
      'totalRecords': totalRecords,
      'presentCount': presentCount,
      'attendanceRate': totalRecords > 0 ? (presentCount / totalRecords * 100).toStringAsFixed(1) : '0.0',
    };
  }
}
