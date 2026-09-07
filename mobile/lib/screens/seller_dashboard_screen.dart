import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'admin_panel_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة الحسابات والدخول - CarZ Portal"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Logo & Portal Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.person, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              "بوابة الدخول وإدارة الإعلانات",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            const SizedBox(height: 6),
            const Text(
              "قم بتسجيل الدخول لنشر سياراتك وإدارتها وإيصالها لآلاف المشترين في العراق",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 30),

            // 1. Button: Login
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.login, color: Colors.black),
                label: const Text(
                  "تسجيل الدخول (Login)",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
              ),
            ),
            const SizedBox(height: 14),

            // 2. Button: Register
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryGold, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: AppTheme.cardDark,
                ),
                icon: const Icon(Icons.person_add, color: AppTheme.primaryGold),
                label: const Text(
                  "إنشاء حساب جديد (Register)",
                  style: TextStyle(color: AppTheme.primaryGold, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                },
              ),
            ),
            const SizedBox(height: 14),

            // 3. Button: Admin Login (خاص بالأدمن فقط)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.accentBlue),
                  ),
                ),
                icon: const Icon(Icons.admin_panel_settings, color: AppTheme.accentBlue),
                label: const Text(
                  "دخول المشرف (Admin Login)",
                  style: TextStyle(color: AppTheme.accentBlue, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
