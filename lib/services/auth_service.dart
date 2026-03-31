import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_id';
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;

  /// Hash a password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Register a new user
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
    String? enrollmentId,
    String? employeeId,
  }) async {
    final db = DatabaseService.instance;

    // Check if email already exists
    final existing = await db.getUserByEmail(email);
    if (existing != null) return false;

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      passwordHash: hashPassword(password),
      role: role,
      department: department,
      enrollmentId: enrollmentId,
      employeeId: employeeId,
    );

    await db.insertUser(user);
    return true;
  }

  /// Login with email & password
  static Future<UserModel?> login(String email, String password) async {
    final db = DatabaseService.instance;
    final user = await db.getUserByEmail(email);
    if (user == null) return null;
    if (user.passwordHash != hashPassword(password)) return null;

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, user.id);
    return user;
  }

  /// Auto-login from saved session
  static Future<UserModel?> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final db = DatabaseService.instance;
    final user = await db.getUserById(userId);
    if (user != null) _currentUser = user;
    return user;
  }

  /// Logout
  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Seed demo users (for first-run)
  static Future<void> seedDemoUsers() async {
    final db = DatabaseService.instance;
    final existing = await db.getUserByEmail('admin@edutrack.com');
    if (existing != null) return; // already seeded

    final users = [
      UserModel(
        id: 'admin_001',
        name: 'Admin User',
        email: 'admin@edutrack.com',
        passwordHash: hashPassword('admin123'),
        role: UserRole.admin,
        department: 'Administration',
      ),
      UserModel(
        id: 'inst_001',
        name: 'Dr. Priya Sharma',
        email: 'priya@edutrack.com',
        passwordHash: hashPassword('inst123'),
        role: UserRole.instructor,
        department: 'Computer Science',
        employeeId: 'EMP001',
      ),
      UserModel(
        id: 'inst_002',
        name: 'Prof. Rahul Mehta',
        email: 'rahul@edutrack.com',
        passwordHash: hashPassword('inst123'),
        role: UserRole.instructor,
        department: 'Information Technology',
        employeeId: 'EMP002',
      ),
      UserModel(
        id: 'stu_001',
        name: 'Ananya Desai',
        email: 'ananya@edutrack.com',
        passwordHash: hashPassword('stu123'),
        role: UserRole.student,
        department: 'Computer Science',
        enrollmentId: 'D23IT101',
      ),
      UserModel(
        id: 'stu_002',
        name: 'Rohan Patil',
        email: 'rohan@edutrack.com',
        passwordHash: hashPassword('stu123'),
        role: UserRole.student,
        department: 'Computer Science',
        enrollmentId: 'D23IT102',
      ),
      UserModel(
        id: 'stu_003',
        name: 'Sneha Kulkarni',
        email: 'sneha@edutrack.com',
        passwordHash: hashPassword('stu123'),
        role: UserRole.student,
        department: 'Information Technology',
        enrollmentId: 'D23IT103',
      ),
    ];

    for (final u in users) {
      await db.insertUser(u);
    }
  }
}
