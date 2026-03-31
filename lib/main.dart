import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'utils/app_theme.dart';
import 'screens/admin/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/instructor/instructor_dashboard.dart';
import 'screens/student/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize DB and seed demo data
  await DatabaseService.instance.database;
  await AuthService.seedDemoUsers();

  // Auto-login check
  final user = await AuthService.autoLogin();

  runApp(EduTrackApp(initialUser: user));
}

class EduTrackApp extends StatelessWidget {
  final UserModel? initialUser;
  const EduTrackApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduTrack – Smart Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _resolveHome(),
    );
  }

  Widget _resolveHome() {
    if (initialUser == null) return const LoginScreen();
    switch (initialUser!.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.instructor:
        return const InstructorDashboard();
      case UserRole.student:
        return const StudentDashboard();
    }
  }
}
