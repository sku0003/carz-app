import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_api.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAuthenticated = false;
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  String _adminTab = 'cars'; // 'cars' | 'users' | 'stats'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Text("دخول مشرفي CarZ", style: TextStyle(color: AppTheme.textPrimaryDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("أدخل كلمة مرور المشرف للوصول للوحة التحكم:", style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: AppTheme.textPrimaryDark),
              decoration: const InputDecoration(
                hintText: "كلمة مرور المشرف",
                filled: true,
                fillColor: AppTheme.darkBackground,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimaryDark),
              decoration: const InputDecoration(
                hintText: "رمز المصادقة الثنائية",
                filled: true,
                fillColor: AppTheme.darkBackground,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("إلغاء", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
            onPressed: () async {
              try {
                await AuthApi.adminLogin(_passwordController.text, _codeController.text);
                if (!mounted || !ctx.mounted) return;
                setState(() => _isAuthenticated = true);
                Navigator.pop(ctx);
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                );
              }
            },
            child: const Text("تأكيد الدخول", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text("لوحة التحكم المشرفين")),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
      );
    }

    final carProvider = Provider.of<CarProvider>(context);
    final cars = carProvider.cars;
    final vipCarsCount = carProvider.vipCars.length;
    final totalViews = cars.fold<int>(0, (acc, c) => acc + c.viewsCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة المشرف والإدارة - CarZ Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryGold),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin Category Selector Header
          Container(
            color: AppTheme.cardDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton("إدارة الإعلانات", 'cars', Icons.directions_car),
                _buildTabButton("إدارة المستخدمين", 'users', Icons.people),
                _buildTabButton("الإحصائيات العامة", 'stats', Icons.analytics),
              ],
            ),
          ),

          Expanded(
            child: _adminTab == 'cars'
                ? _buildCarsManagement(cars, carProvider)
                : _adminTab == 'users'
                    ? _buildUsersManagement()
                    : _buildStatsView(cars.length, vipCarsCount, totalViews),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String tabKey, IconData icon) {
    final isSel = _adminTab == tabKey;
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: isSel ? AppTheme.primaryGold : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      icon: Icon(icon, size: 16, color: isSel ? Colors.black : AppTheme.textSecondaryDark),
      label: Text(
        title,
        style: TextStyle(
          color: isSel ? Colors.black : AppTheme.textSecondaryDark,
          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      onPressed: () => setState(() => _adminTab = tabKey),
    );
  }

  // Cars Management Tab (Includes manual VIP activation toggle button!)
  Widget _buildCarsManagement(List cars, CarProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: car.isVIP ? AppTheme.primaryGold : AppTheme.cardBorderDark),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  car.images.isNotEmpty ? car.images.first : '',
                  width: 75,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 75, height: 60, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                    const SizedBox(height: 4),
                    Text("البائع: ${car.sellerName} | \$${car.priceUSD.toInt()}", style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Manual VIP Toggle Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: car.isVIP ? Colors.amber.shade900 : AppTheme.primaryGold,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          icon: Icon(car.isVIP ? Icons.star : Icons.workspace_premium, size: 14, color: Colors.black),
                          label: Text(
                            car.isVIP ? "إلغاء VIP" : "تفعيل VIP يدوياً",
                            style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            provider.upgradeToVIP(car.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(car.isVIP ? "تم تحديث حالة الإعلان إلى مميز VIP!" : "تم التعديل بنجاح"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Users Management Tab
  Widget _buildUsersManagement() {
    final mockUsers = [
      {'name': 'معرض الرافدين', 'phone': '+966562514125', 'status': 'نشط'},
      {'name': 'حسين الكردي', 'phone': '+9647509876543', 'status': 'نشط'},
      {'name': 'علي البغدادي', 'phone': '+9647718899001', 'status': 'نشط'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: mockUsers.length,
      itemBuilder: (context, index) {
        final u = mockUsers[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryGold,
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(u['phone']!),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم تنفيذ الإجراء: $val للمستخدم ${u['name']}")),
                );
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'suspend', child: Text("حظر / تعليق الحساب")),
                const PopupMenuItem(value: 'delete', child: Text("حذف الحساب")),
              ],
            ),
          ),
        );
      },
    );
  }

  // General Analytics Tab
  Widget _buildStatsView(int totalCars, int vipCars, int totalViews) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatRow("عدد الإعلانات الكلي", "$totalCars", Icons.directions_car),
          const SizedBox(height: 12),
          _buildStatRow("عدد إعلانات CarZ VIP المميزة", "$vipCars", Icons.workspace_premium),
          const SizedBox(height: 12),
          _buildStatRow("إجمالي مشاهدات المنصة", "$totalViews", Icons.remove_red_eye),
          const SizedBox(height: 12),
          _buildStatRow("عدد طلبات الترقية عبر الواتساب", "18 طلب هذا الأسبوع", Icons.chat_bubble),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGold),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(val, style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
