import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_api.dart';
import 'legal_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isOtpSent = false;
  bool _isRegister = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تسجيل الدخول / حساب جديد"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGold,
          labelColor: AppTheme.primaryGold,
          unselectedLabelColor: AppTheme.textSecondaryDark,
          tabs: const [
            Tab(text: "رقم الهاتف (OTP)"),
            Tab(text: "البريد الإلكتروني"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Branding Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.cardDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_pin, size: 50, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 16),
            const Text(
              "مرحباً بك في CarZ سوق السيارات العراقي",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            const SizedBox(height: 24),

            // Tab Views
            SizedBox(
              height: 240,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Phone OTP Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("رقم الهاتف (العراق +964):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: AppTheme.textPrimaryDark),
                        decoration: _buildInputDecoration("0770XXXXXXX"),
                      ),
                      if (_isOtpSent) ...[
                        const SizedBox(height: 12),
                        const Text("رمز التحقق:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.textPrimaryDark),
                          decoration: _buildInputDecoration("أدخل الرمز 1234"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
                          child: const Text('سياسة الخصوصية وشروط الاستخدام'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                          onPressed: _isSubmitting ? null : _submitPhoneAuth,
                          child: Text(
                            _isOtpSent ? "تأكيد الرمز والدخول" : "إرسال رمز التحقق OTP",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Email & Password Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isRegister) ...[
                        const Text("الاسم:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: AppTheme.textPrimaryDark),
                          decoration: _buildInputDecoration("الاسم الكامل"),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Text(_isRegister ? "البريد الإلكتروني لإنشاء الحساب:" : "البريد الإلكتروني:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.textPrimaryDark),
                        decoration: _buildInputDecoration("example@domain.com"),
                      ),
                      const SizedBox(height: 10),
                      const Text("كلمة المرور:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppTheme.textPrimaryDark),
                        decoration: _buildInputDecoration("******"),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
                          onPressed: _isSubmitting ? null : _submitEmailAuth,
                          child: Text(_isSubmitting ? "جارٍ المعالجة..." : (_isRegister ? "إنشاء الحساب" : "تسجيل الدخول"), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => _isRegister = !_isRegister),
                          child: Text(_isRegister ? "لديك حساب؟ تسجيل الدخول" : "ليس لديك حساب؟ إنشاء حساب جديد"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _submitEmailAuth() async {
    setState(() => _isSubmitting = true);
    try {
      final name = await AuthApi.authenticate(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        register: _isRegister,
        name: _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("مرحباً $name"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitPhoneAuth() async {
    setState(() => _isSubmitting = true);
    try {
      if (!_isOtpSent) {
        await AuthApi.requestPhoneOtp(_phoneController.text.trim());
        if (!mounted) return;
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال رمز التحقق")));
      } else {
        final name = await AuthApi.verifyPhoneOtp(_phoneController.text.trim(), _otpController.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("مرحباً $name"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
      filled: true,
      fillColor: AppTheme.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGold)),
    );
  }
}
