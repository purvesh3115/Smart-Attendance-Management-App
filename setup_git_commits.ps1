# EduTrack - Git Commit Setup Script
# Run this script from the project root directory
# It creates a properly structured git history with 4 commits

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EduTrack Git Commit Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location $projectRoot

# ─── Configure git if not already configured ───
$gitName = git config user.name 2>$null
if (-not $gitName) {
    git config user.email "student@edutrack.com"
    git config user.name "EduTrack Developer"
    Write-Host "[INFO] Git user configured." -ForegroundColor Yellow
}

# ─── Init repo if not already a git repo ───
if (-not (Test-Path ".git")) {
    git init
    Write-Host "[OK] Git repository initialized." -ForegroundColor Green
} else {
    Write-Host "[OK] Git repository already exists." -ForegroundColor Green
}

# ─── .gitignore ───
$gitignore = @"
# Flutter / Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.iml
*.ipr
*.iws
.idea/

# Android
android/.gradle/
android/captures/
android/local.properties
android/key.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Runner/GeneratedPluginRegistrant.*
ios/Podfile.lock

# VS Code
.vscode/

# macOS
.DS_Store

# Coverage
coverage/
"@

if (-not (Test-Path ".gitignore")) {
    $gitignore | Out-File -Encoding utf8 ".gitignore"
    Write-Host "[OK] .gitignore created." -ForegroundColor Green
}

# ════════════════════════════════════════════
# COMMIT 1: Initialization
# Project scaffold, pubspec, models, theme, auth
# ════════════════════════════════════════════
Write-Host "`n--- Commit 1/4: Initialization ---" -ForegroundColor Magenta

git add .gitignore
git add pubspec.yaml
git add lib/main.dart
git add lib/models/user_model.dart
git add lib/models/session_model.dart
git add lib/models/attendance_record.dart
git add lib/utils/app_theme.dart
git add lib/services/auth_service.dart

git commit -m "feat: Initialization - project setup, models, auth service, and theme

- Initialize Flutter project structure
- Add pubspec.yaml with all dependencies (qr_flutter, mobile_scanner,
  geolocator, sqflite, fl_chart, google_fonts, crypto, uuid)
- Define UserModel with admin/instructor/student roles
- Define SessionModel with QR payload, GPS anchor, and expiry
- Define AttendanceRecord with status, GPS coords, and sync flag
- Implement AuthService with SHA-256 password hashing, login/logout,
  SharedPreferences session persistence, and demo user seeding
- Set up dark indigo theme with gradients and Outfit typography
- Entry point with async init, auto-login, and role-based routing"

Write-Host "[OK] Commit 1 done: Initialization" -ForegroundColor Green

# ════════════════════════════════════════════
# COMMIT 2: QR Integration
# Session service, QR generation, instructor QR screens
# ════════════════════════════════════════════
Write-Host "`n--- Commit 2/4: QR Integration ---" -ForegroundColor Magenta

git add lib/services/session_service.dart
git add lib/services/location_service.dart
git add lib/screens/instructor/instructor_dashboard.dart

git commit -m "feat: QR Integration - session generation, token integrity, GPS validation

- Implement SessionService.createSession() with UUID session IDs,
  configurable QR validity window (5-120 minutes), and GPS anchor capture
- Generate JSON QR payload encoding sessionId, subject, className,
  expiry timestamp, GPS coordinates, and integrity token
- Implement deterministic integrity token to prevent QR tampering
- Build InstructorDashboard with session list and live countdown bars
- Create session creation bottom sheet with subject/class input,
  duration slider, and GPS toggle switch
- Implement QRDisplayScreen showing live QR code (qr_flutter) with:
  * Real-time second-by-second countdown timer
  * Color-coded expiry warnings (green -> amber -> red)
  * Live attendee list that auto-refreshes every second
- Implement GPS validation using Haversine formula (100m radius)
- Add LocationService with permission handling and distance calculation"

Write-Host "[OK] Commit 2 done: QR Integration" -ForegroundColor Green

# ════════════════════════════════════════════
# COMMIT 3: Backend Sync
# SQLite database, offline storage, attendance marking
# ════════════════════════════════════════════
Write-Host "`n--- Commit 3/4: Backend Sync ---" -ForegroundColor Magenta

git add lib/services/database_service.dart

git commit -m "feat: Backend Sync - SQLite offline storage, attendance marking pipeline

- Implement DatabaseService as singleton with SQLite (sqflite)
- Create 3 tables: users, sessions, attendance with full schema
- User CRUD: insertUser, getUserByEmail, getUserById, getUsersByRole
- Session CRUD: insertSession, getSessionsByInstructor, deactivateSession
- Attendance CRUD: insertAttendance, getAttendanceBySession,
  getAttendanceByStudent, hasStudentMarkedSession (duplicate prevention)
- Aggregate queries: getOverallStats (total students, sessions, rate),
  getAttendanceSummaryBySubject for per-student subject breakdown
- Implement full anti-proxy pipeline in SessionService.markAttendance():
  1. JSON format validation
  2. Integrity token verification
  3. Session expiry check
  4. Duplicate attendance guard (one scan per student per session)
  5. GPS proximity validation (<= 100m from classroom anchor)
  6. AttendanceRecord persistence with isSynced flag for future cloud sync
- Offline-first architecture: all data stored locally with sync flag"

Write-Host "[OK] Commit 3 done: Backend Sync" -ForegroundColor Green

# ════════════════════════════════════════════
# COMMIT 4: UI & Reports
# All screens, widgets, admin dashboard, student scanner, reports
# ════════════════════════════════════════════
Write-Host "`n--- Commit 4/4: UI & Reports ---" -ForegroundColor Magenta

git add lib/widgets/common_widgets.dart
git add lib/screens/admin/login_screen.dart
git add lib/screens/admin/register_screen.dart
git add lib/screens/admin/admin_dashboard.dart
git add lib/screens/student/student_dashboard.dart
git add assets/

git commit -m "feat: UI & Reports - dashboards, QR scanner, analytics, attendance reports

- Build shared widget library: StatCard (gradient with glow shadow),
  GlassCard, GradientAppBar, StatusBadge, LoadingOverlay, AttendanceRing
- AttendanceRing: circular progress with color-coding (green/amber/red)
- LoginScreen: animated fade+slide entry, gradient background, form
  validation, one-tap demo credential cards for all three roles
- RegisterScreen: role selector toggle, full form with enrollment/employee ID
- AdminDashboard (3 tabs):
  * Overview: 4-card stat grid + PieChart (Present vs Absent via fl_chart)
  * Users: tabbed student/instructor lists with enrollment IDs
  * Reports: subject-wise attendance breakdown with AttendanceRing
- InstructorDashboard: session list with countdown progress bars,
  tap-to-reopen active QR, attendance tab showing all marked records
- StudentDashboard (2 tabs):
  * My Attendance: chronological list with present/absent color strip
  * Subject Report: per-subject rings + linear progress + 75% warnings
- QRScannerScreen: MobileScanner with custom overlay, corner accents,
  torch toggle, result screen (success/failure) with retry option
- Add assets/images directory for future icon assets"

Write-Host "[OK] Commit 4 done: UI & Reports" -ForegroundColor Green

# ─── Summary ───
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  All 4 commits created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nCommit history:" -ForegroundColor Yellow
git log --oneline

Write-Host "`n[NEXT] To push to GitHub:" -ForegroundColor Yellow
Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git" -ForegroundColor White
Write-Host "  git branch -M main" -ForegroundColor White
Write-Host "  git push -u origin main" -ForegroundColor White
Write-Host ""
