import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_car_screen.dart';
import 'favorites_screen.dart';
import 'seller_dashboard_screen.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AddCarScreen(),
    FavoritesScreen(),
    SellerDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: AppTheme.textSecondaryDark,
        backgroundColor: AppTheme.cardDark,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            activeIcon: Icon(Icons.directions_car_filled, color: AppTheme.primaryGold),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle, color: AppTheme.primaryGold),
            label: "إضافة إعلان",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite, color: AppTheme.primaryGold),
            label: "المفضلة",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard, color: AppTheme.primaryGold),
            label: "لوحة البائع",
          ),
        ],
      ),
    );
  }
}
