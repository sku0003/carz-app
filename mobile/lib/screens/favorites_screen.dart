import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../theme/app_theme.dart';
import 'car_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final favCars = carProvider.favoriteCars;

    return Scaffold(
      appBar: AppBar(
        title: Text("المفضلة والتنبيهات (${favCars.length})"),
      ),
      body: favCars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 70, color: AppTheme.textSecondaryDark),
                  const SizedBox(height: 14),
                  const Text("قائمة المفضلة فارغة حالياً", style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("انقر على أيقونة القلب على أي إعلان لحفظه وتلقي إشعارات تنزيل الأسعار",
                      textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: favCars.length,
              itemBuilder: (context, index) {
                final car = favCars[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CarDetailsScreen(carId: car.id)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorderDark),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            car.images.isNotEmpty ? car.images.first : '',
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 100, height: 80, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(car.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
                              const SizedBox(height: 4),
                              Text("\$${car.priceUSD.toInt()} | ${car.governorate}", style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (car.priceHistory.length > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.shade900, borderRadius: BorderRadius.circular(6)),
                                  child: const Text("تنبيه: انخفض السعر مؤخراً!", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.redAccent),
                          onPressed: () => carProvider.toggleFavorite(car.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
