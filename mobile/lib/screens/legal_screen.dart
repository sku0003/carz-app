import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخصوصية والشروط')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سياسة الخصوصية', style: TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('نجمع البيانات اللازمة لإنشاء الحساب وتشغيل الإعلانات فقط. كلمات المرور تحفظ باستخدام bcrypt ولا نخزن بيانات البطاقات أو المعلومات المصرفية. تستخدم الاتصالات HTTPS عند النشر. يمكنك طلب حذف حسابك وبياناتك من إدارة CarZ.'),
            SizedBox(height: 24),
            Text('شروط الاستخدام', style: TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('يجب أن تكون الإعلانات حقيقية ومملوكة للمستخدم أو مصرحاً له بنشرها. يمنع نشر محتوى مضلل أو ضار أو مخالف للقانون. يحتفظ CarZ بحق مراجعة الإعلان وإيقاف الحساب المخالف.'),
          ],
        ),
      ),
    );
  }
}
