import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_model.dart';
import '../../models/attendance_record.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  Map<String, dynamic> _stats = {};
  List<UserModel> _students = [];
  List<UserModel> _instructors = [];
  List<AttendanceRecord> _attendance = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseService.instance;
    final stats = await db.getOverallStats();
    final students = await db.getUsersByRole(UserRole.student);
    final instructors = await db.getUsersByRole(UserRole.instructor);
    final attendance = await db.getAllAttendance();
    setState(() {
      _stats = stats;
      _students = students;
      _instructors = instructors;
      _attendance = attendance;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;
    return Scaffold(
      body: Column(
        children: [
          // Custom header
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Dashboard',
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Welcome, ${user.name}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_outlined, color: Colors.white),
                          onPressed: () {
                            setState(() => _loading = true);
                            _loadData();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabCtrl,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Users'),
                    Tab(text: 'Reports'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildOverview(),
                      _buildUsers(),
                      _buildReports(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    final rate = double.tryParse(_stats['attendanceRate']?.toString() ?? '0') ?? 0;
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  title: 'Total Students',
                  value: '${_stats['totalStudents'] ?? 0}',
                  icon: Icons.school_outlined,
                  gradient: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                ),
                StatCard(
                  title: 'Instructors',
                  value: '${_instructors.length}',
                  icon: Icons.person_pin_outlined,
                  gradient: [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
                ),
                StatCard(
                  title: 'Total Sessions',
                  value: '${_stats['totalSessions'] ?? 0}',
                  icon: Icons.qr_code_rounded,
                  gradient: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                ),
                StatCard(
                  title: 'Attendance Rate',
                  value: '${rate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up_rounded,
                  gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            Text('Attendance Overview',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: (_stats['presentCount'] ?? 0).toDouble(),
                        color: AppTheme.success,
                        title: 'Present',
                        titleStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        radius: 55,
                      ),
                      PieChartSectionData(
                        value: ((_stats['totalRecords'] ?? 0) -
                                (_stats['presentCount'] ?? 0))
                            .toDouble(),
                        color: AppTheme.error,
                        title: 'Absent',
                        titleStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        radius: 55,
                      ),
                    ],
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent activity
            Text('Recent Attendance',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 12),
            ..._attendance.take(8).map((r) => _attendanceTile(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsers() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppTheme.surfaceCard,
            child: TabBar(
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primary,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: 'Students (${_students.length})'),
                Tab(text: 'Instructors (${_instructors.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _userList(_students, UserRole.student),
                _userList(_instructors, UserRole.instructor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userList(List<UserModel> users, UserRole role) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == UserRole.student
                  ? Icons.school_outlined
                  : Icons.person_pin_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 12),
            Text('No ${role.name}s registered',
                style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final u = users[i];
        return GlassCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(u.name,
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text(u.email, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (u.enrollmentId != null)
                  Text(u.enrollmentId!,
                      style:
                          const TextStyle(color: AppTheme.accent, fontSize: 11)),
                if (u.employeeId != null)
                  Text(u.employeeId!,
                      style:
                          const TextStyle(color: AppTheme.accent, fontSize: 11)),
                if (u.department != null)
                  Text(u.department!,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReports() {
    // Group attendance by subject
    final Map<String, List<AttendanceRecord>> bySubject = {};
    for (final r in _attendance) {
      bySubject.putIfAbsent(r.subject, () => []).add(r);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject-wise Report',
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          if (bySubject.isEmpty)
            const GlassCard(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No attendance data yet.',
                    style: TextStyle(color: AppTheme.textMuted)),
              )),
            )
          else
            ...bySubject.entries.map((e) {
              final total = e.value.length;
              final present =
                  e.value.where((r) => r.status == AttendanceStatus.present).length;
              final pct = total > 0 ? (present / total * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(e.key,
                                style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                          AttendanceRing(percentage: pct.toDouble()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _reportChip('Total', '$total', AppTheme.textMuted),
                          const SizedBox(width: 8),
                          _reportChip('Present', '$present', AppTheme.success),
                          const SizedBox(width: 8),
                          _reportChip('Absent', '${total - present}', AppTheme.error),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _reportChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _attendanceTile(AttendanceRecord r) {
    final isPresent = r.status == AttendanceStatus.present;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: isPresent ? AppTheme.success : AppTheme.error,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.studentName,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text('${r.subject} • ${r.className}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            StatusBadge(
              label: isPresent ? 'Present' : 'Absent',
              color: isPresent ? AppTheme.success : AppTheme.error,
              icon: isPresent ? Icons.check_circle_outline : Icons.cancel_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
