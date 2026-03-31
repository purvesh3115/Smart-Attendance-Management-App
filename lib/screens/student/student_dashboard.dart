import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_record.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../admin/login_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<AttendanceRecord> _records = [];
  bool _loading = true;
  Map<String, double> _subjectPct = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final user = AuthService.currentUser!;
    final records =
        await DatabaseService.instance.getAttendanceByStudent(user.id);
    final Map<String, int> totalMap = {};
    final Map<String, int> presentMap = {};
    for (final r in records) {
      totalMap[r.subject] = (totalMap[r.subject] ?? 0) + 1;
      if (r.status == AttendanceStatus.present) {
        presentMap[r.subject] = (presentMap[r.subject] ?? 0) + 1;
      }
    }
    final Map<String, double> pctMap = {};
    for (final subj in totalMap.keys) {
      final t = totalMap[subj]!;
      final p = presentMap[subj] ?? 0;
      pctMap[subj] = t > 0 ? p / t * 100 : 0;
    }
    setState(() {
      _records = records;
      _subjectPct = pctMap;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(
          onSuccess: () {
            setState(() => _loading = true);
            _loadRecords();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;
    final totalSessions = _records.length;
    final present =
        _records.where((r) => r.status == AttendanceStatus.present).length;
    final overallPct =
        totalSessions > 0 ? (present / totalSessions * 100) : 0.0;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.successGradient),
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
                        Text('Student Portal',
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text(user.name,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13)),
                        if (user.enrollmentId != null)
                          Text(user.enrollmentId!,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 11)),
                      ],
                    ),
                    Row(children: [
                      AttendanceRing(
                          percentage: overallPct.toDouble(), size: 64),
                      const SizedBox(width: 8),
                      IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white),
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
                    Tab(text: 'My Attendance'),
                    Tab(text: 'Subject Report'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.success))
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildAttendanceTab(),
                      _buildSubjectReport(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        backgroundColor: AppTheme.success,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
        label: Text('Scan QR',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner_outlined,
                size: 80, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No attendance yet',
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            const Text('Scan a QR code in class to mark attendance',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      color: AppTheme.success,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final r = _records[i];
          final isPresent = r.status == AttendanceStatus.present;
          return GlassCard(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 56,
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
                      Text(r.subject,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14)),
                      Text('${r.className} • ${DateFormat('dd MMM yyyy').format(r.markedAt)}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                      Text(DateFormat('hh:mm a').format(r.markedAt),
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    StatusBadge(
                      label: isPresent ? 'Present' : 'Absent',
                      color: isPresent ? AppTheme.success : AppTheme.error,
                      icon: isPresent
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                    ),
                    if (r.latitude != null) ...[
                      const SizedBox(height: 4),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textMuted),
                    ],
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubjectReport() {
    if (_subjectPct.isEmpty) {
      return const Center(
        child: Text('No data yet. Attend some classes first!',
            style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attendance Warning',
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warning)),
              const SizedBox(height: 4),
              Text('Subjects below 75% are highlighted in red',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._subjectPct.entries.map((e) {
          final pct = e.value;
          final color = pct >= 75
              ? AppTheme.success
              : pct >= 60
                  ? AppTheme.warning
                  : AppTheme.error;

          final totalForSubj =
              _records.where((r) => r.subject == e.key).length;
          final presentForSubj = _records
              .where((r) =>
                  r.subject == e.key && r.status == AttendanceStatus.present)
              .length;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.key,
                                style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            Text(
                                '$presentForSubj / $totalForSubj classes attended',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      AttendanceRing(percentage: pct),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                  if (pct < 75) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: AppTheme.warning),
                        const SizedBox(width: 4),
                        Text(
                          pct < 60
                              ? 'Critical: Below 60% — risk of detention'
                              : 'Low: Below 75% — needs improvement',
                          style: TextStyle(
                              color: AppTheme.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────── QR Scanner Screen ───────────────
class QRScannerScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const QRScannerScreen({super.key, required this.onSuccess});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  bool _done = false;
  String? _resultMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _done) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _processing = true);
    await _controller.stop();

    final result = await SessionService.markAttendance(
      qrPayload: barcode!.rawValue!,
      student: AuthService.currentUser!,
    );

    setState(() {
      _done = true;
      _processing = false;
      _isSuccess = result.success;
      _resultMessage = result.success
          ? 'Attendance marked for ${result.record?.subject}!\n${result.session?.className}'
          : result.errorMessage ?? 'An error occurred.';
    });

    if (result.success) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scan QR Code',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: _done ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        // Overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Transparent scan window
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.success, width: 3),
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
          ),
        ),
        // Corner accents
        ..._corners(),
        Positioned(
          bottom: 100,
          child: Column(
            children: [
              if (_processing)
                const CircularProgressIndicator(color: AppTheme.success)
              else ...[
                const Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white54, size: 28),
                const SizedBox(height: 8),
                Text('Align QR code within the frame',
                    style: GoogleFonts.outfit(
                        color: Colors.white70, fontSize: 14)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _corners() {
    const size = 24.0;
    const thick = 4.0;
    const color = AppTheme.success;
    const r = 8.0;
    return [
      // Top-left
      Positioned(
        top: (MediaQuery.of(context).size.height - 260) / 2,
        left: (MediaQuery.of(context).size.width - 260) / 2,
        child: _corner(color, size, thick, r, top: true, left: true),
      ),
      Positioned(
        top: (MediaQuery.of(context).size.height - 260) / 2,
        right: (MediaQuery.of(context).size.width - 260) / 2,
        child: _corner(color, size, thick, r, top: true, left: false),
      ),
      Positioned(
        bottom: (MediaQuery.of(context).size.height - 260) / 2,
        left: (MediaQuery.of(context).size.width - 260) / 2,
        child: _corner(color, size, thick, r, top: false, left: true),
      ),
      Positioned(
        bottom: (MediaQuery.of(context).size.height - 260) / 2,
        right: (MediaQuery.of(context).size.width - 260) / 2,
        child: _corner(color, size, thick, r, top: false, left: false),
      ),
    ];
  }

  Widget _corner(Color c, double s, double t, double r,
      {required bool top, required bool left}) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: c, width: t) : BorderSide.none,
          bottom: !top ? BorderSide(color: c, width: t) : BorderSide.none,
          left: left ? BorderSide(color: c, width: t) : BorderSide.none,
          right: !left ? BorderSide(color: c, width: t) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? Radius.circular(r) : Radius.zero,
          topRight: top && !left ? Radius.circular(r) : Radius.zero,
          bottomLeft: !top && left ? Radius.circular(r) : Radius.zero,
          bottomRight: !top && !left ? Radius.circular(r) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isSuccess ? AppTheme.success : AppTheme.error)
                    .withOpacity(0.15),
                border: Border.all(
                  color: _isSuccess ? AppTheme.success : AppTheme.error,
                  width: 3,
                ),
              ),
              child: Icon(
                _isSuccess ? Icons.check_rounded : Icons.close_rounded,
                size: 64,
                color: _isSuccess ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isSuccess ? 'Attendance Marked!' : 'Failed',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _isSuccess ? AppTheme.success : AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _resultMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isSuccess)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _done = false;
                          _processing = false;
                          _resultMessage = null;
                        });
                        _controller.start();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary),
                    ),
                  ),
                if (!_isSuccess) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSuccess ? AppTheme.success : AppTheme.surfaceCard),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
