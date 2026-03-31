import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../models/attendance_record.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/login_screen.dart';

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({super.key});

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<SessionModel> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final user = AuthService.currentUser!;
    final sessions =
        await DatabaseService.instance.getSessionsByInstructor(user.id);
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _showCreateSessionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSessionSheet(
        onCreated: (session) {
          setState(() => _sessions.insert(0, session));
          Navigator.pop(context);
          _showQRDialog(session);
        },
      ),
    );
  }

  void _showQRDialog(SessionModel session) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => QRDisplayScreen(session: session)));
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
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
                        Text('Instructor Portal',
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(user.name,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13)),
                      ],
                    ),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.refresh_outlined,
                              color: Colors.white),
                          onPressed: () {
                            setState(() => _loading = true);
                            _loadSessions();
                          }),
                      IconButton(
                          icon:
                              const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: _logout),
                    ]),
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
                    Tab(text: 'My Sessions'),
                    Tab(text: 'Attendance'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent))
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildSessionsTab(),
                      _buildAttendanceTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSessionDialog,
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
        label: Text('New Session',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSessionsTab() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_outlined, size: 72, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No sessions yet',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            const Text('Tap the button below to create a QR session',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: AppTheme.accent,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final s = _sessions[i];
          final expired = s.isExpired;
          return GestureDetector(
            onTap: expired ? null : () => _showQRDialog(s),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(s.subject,
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      StatusBadge(
                        label: expired ? 'Expired' : 'Active',
                        color: expired ? AppTheme.error : AppTheme.success,
                        icon: expired
                            ? Icons.timer_off_outlined
                            : Icons.qr_code_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Class: ${s.className}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(s.startTime),
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                      if (s.latitude != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppTheme.accent),
                        const Text(' GPS Enabled',
                            style: TextStyle(
                                color: AppTheme.accent, fontSize: 11)),
                      ],
                    ],
                  ),
                  if (!expired) ...[
                    const SizedBox(height: 10),
                    _CountdownBar(session: s),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return FutureBuilder<List<AttendanceRecord>>(
      future: _buildAttendanceList(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent));
        }
        final records = snap.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Text('No attendance records yet.',
                style: TextStyle(color: AppTheme.textMuted)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final r = records[i];
            return GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.success.withOpacity(0.15),
                  child: Text(r.studentName[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.success, fontWeight: FontWeight.w700)),
                ),
                title: Text(r.studentName,
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text('${r.subject} • ${DateFormat('dd MMM, hh:mm a').format(r.markedAt)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: StatusBadge(
                  label: r.status.name,
                  color: r.status == AttendanceStatus.present
                      ? AppTheme.success
                      : AppTheme.error,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<AttendanceRecord>> _buildAttendanceList() async {
    final user = AuthService.currentUser!;
    final sessions =
        await DatabaseService.instance.getSessionsByInstructor(user.id);
    final List<AttendanceRecord> records = [];
    for (final s in sessions) {
      final recs = await DatabaseService.instance.getAttendanceBySession(s.id);
      records.addAll(recs);
    }
    records.sort((a, b) => b.markedAt.compareTo(a.markedAt));
    return records;
  }
}

// ─────────────── Create Session Sheet ───────────────
class _CreateSessionSheet extends StatefulWidget {
  final Function(SessionModel) onCreated;
  const _CreateSessionSheet({required this.onCreated});

  @override
  State<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<_CreateSessionSheet> {
  final _subjectCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  int _duration = 30;
  bool _useGps = true;
  bool _loading = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _classCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_subjectCtrl.text.isEmpty || _classCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final session = await SessionService.createSession(
        instructor: AuthService.currentUser!,
        subject: _subjectCtrl.text.trim(),
        className: _classCtrl.text.trim(),
        durationMinutes: _duration,
        useGps: _useGps,
      );
      if (mounted) {
        setState(() => _loading = false);
        widget.onCreated(session);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate session: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.divider.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Create QR Session',
              style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Generate a time-bound QR code for attendance',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 20),
          TextField(
            controller: _subjectCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Subject',
              prefixIcon: Icon(Icons.book_outlined, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _classCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Class / Division',
              prefixIcon: Icon(Icons.class_outlined, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 16),

          // Duration slider
          Text('QR Validity: $_duration minutes',
              style: GoogleFonts.outfit(
                  color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          Slider(
            value: _duration.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            activeColor: AppTheme.accent,
            inactiveColor: AppTheme.divider,
            label: '$_duration min',
            onChanged: (v) => setState(() => _duration = v.round()),
          ),

          // GPS toggle
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppTheme.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GPS Validation',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text('Students must be within 100m of classroom',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: _useGps,
                  onChanged: (v) => setState(() => _useGps = v),
                  activeColor: AppTheme.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.accent))
                : ElevatedButton.icon(
                    onPressed: _create,
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Generate QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────── QR Display Screen ───────────────
class QRDisplayScreen extends StatefulWidget {
  final SessionModel session;
  const QRDisplayScreen({super.key, required this.session});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  late Timer _timer;
  int _remaining = 0;
  List<AttendanceRecord> _attendees = [];

  @override
  void initState() {
    super.initState();
    _remaining = widget.session.remainingSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.session.remainingSeconds);
      _refreshAttendees();
    });
    _refreshAttendees();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _refreshAttendees() async {
    final records = await DatabaseService.instance
        .getAttendanceBySession(widget.session.id);
    if (mounted) setState(() => _attendees = records);
  }

  @override
  Widget build(BuildContext context) {
    final expired = _remaining <= 0;
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;

    return Scaffold(
      appBar: GradientAppBar(
        title: widget.session.subject,
        subtitle: 'Class: ${widget.session.className}',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white),
            onPressed: _refreshAttendees,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Countdown
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: expired
                    ? const LinearGradient(
                        colors: [AppTheme.error, Color(0xFFB91C1C)])
                    : _remaining < 60
                        ? const LinearGradient(
                            colors: [AppTheme.warning, Color(0xFFD97706)])
                        : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                          expired
                              ? Icons.timer_off_rounded
                              : Icons.timer_rounded,
                          color: Colors.white,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                          expired
                              ? 'Session Expired'
                              : '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} remaining',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (expired)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: const Column(
                        children: [
                          Icon(Icons.qr_code_outlined,
                              size: 80, color: AppTheme.textMuted),
                          SizedBox(height: 12),
                          Text('QR Code Expired',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 16)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: widget.session.qrPayload,
                        version: QrVersions.auto,
                        size: 240,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (!expired) ...[
                    Text('Show this QR code to students',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.session.latitude != null)
                          StatusBadge(
                            label: 'GPS Enabled',
                            color: AppTheme.accent,
                            icon: Icons.location_on_outlined,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Attendees list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Marked Present (${_attendees.length})',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                StatusBadge(
                  label: '${_attendees.length} students',
                  color: AppTheme.success,
                  icon: Icons.people_outline,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_attendees.isEmpty)
              const GlassCard(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text('Waiting for students to scan...',
                        style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ),
              )
            else
              ...(_attendees.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.success.withOpacity(0.15),
                          child: Text(r.studentName[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w700)),
                        ),
                        title: Text(r.studentName,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        trailing: Text(
                            DateFormat('hh:mm a').format(r.markedAt),
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12)),
                      ),
                    ),
                  ))),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Countdown Progress Bar ───────────────
class _CountdownBar extends StatefulWidget {
  final SessionModel session;
  const _CountdownBar({required this.session});

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar> {
  late Timer _timer;
  int _remaining = 0;
  late int _total;

  @override
  void initState() {
    super.initState();
    _total = widget.session.expiryTime
        .difference(widget.session.startTime)
        .inSeconds;
    _remaining = widget.session.remainingSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.session.remainingSeconds);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _total > 0 ? _remaining / _total : 0.0;
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('QR expires in:',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            Text('${mins}m ${secs}s',
                style: TextStyle(
                    color: pct < 0.2 ? AppTheme.warning : AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation(
                pct < 0.2 ? AppTheme.warning : AppTheme.accent),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
