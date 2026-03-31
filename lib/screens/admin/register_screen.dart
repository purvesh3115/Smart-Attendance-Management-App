import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _deptCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final success = await AuthService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole,
      department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      enrollmentId: _selectedRole == UserRole.student ? _idCtrl.text.trim() : null,
      employeeId: _selectedRole == UserRole.instructor ? _idCtrl.text.trim() : null,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Please login.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email already registered. Use a different email.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Create Account',
                        style: GoogleFonts.outfit(
                            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.divider.withOpacity(0.5)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role selector
                        Text('Role',
                            style: GoogleFonts.outfit(
                                fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: UserRole.values
                              .where((r) => r != UserRole.admin)
                              .map((r) => Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedRole = r),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: _selectedRole == r
                                              ? AppTheme.primaryGradient
                                              : null,
                                          color: _selectedRole != r ? AppTheme.surface : null,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedRole == r
                                                ? Colors.transparent
                                                : AppTheme.divider,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            r.name[0].toUpperCase() + r.name.substring(1),
                                            style: TextStyle(
                                              color: _selectedRole == r
                                                  ? Colors.white
                                                  : AppTheme.textMuted,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),

                        _field(_nameCtrl, 'Full Name', Icons.person_outline, (v) =>
                            v == null || v.isEmpty ? 'Enter your name' : null),
                        const SizedBox(height: 14),
                        _field(_emailCtrl, 'Email', Icons.email_outlined, (v) =>
                            v == null || !v.contains('@') ? 'Enter valid email' : null,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMuted),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 14),
                        _field(_deptCtrl, 'Department (optional)', Icons.business_outlined, null),
                        const SizedBox(height: 14),
                        _field(
                            _idCtrl,
                            _selectedRole == UserRole.student
                                ? 'Enrollment ID'
                                : 'Employee ID',
                            Icons.badge_outlined,
                            null),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator(color: AppTheme.primary))
                              : ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Text('Create Account',
                                      style: GoogleFonts.outfit(
                                          fontSize: 16, fontWeight: FontWeight.w700)),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      String? Function(String?)? validator,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textMuted),
      ),
      validator: validator,
    );
  }
}
