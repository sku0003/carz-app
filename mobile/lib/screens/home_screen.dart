import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/car_provider.dart';
import '../theme/app_theme.dart';
import 'car_details_screen.dart';
import 'filter_modal.dart';
import 'auth_screen.dart';
import 'admin_panel_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final List<String> governorates = const [
    'الكل',
    'بغداد',
    'أربيل',
    'البصرة',
    'السليمانية',
    'الموصل',
    'النجف',
    'كربلاء',
    'كركوك',
    'بابل',
    'دهوك'
  ];

  final List<String> brands = const [
    'الكل',
    'تويوتا',
    'هيونداي',
    'كيا',
    'دوج',
    'نيسان',
    'جيب',
    'مرسيدس'
  ];

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "CarZ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text("سوق السيارات العراقي", style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppTheme.primaryGold),
            tooltip: "تسجيل الدخول / حساب جديد",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: AppTheme.accentBlue),
            tooltip: "لوحة الأدمن المشرف",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
            },
          ),
          IconButton(
            icon: Icon(
              carProvider.showInUSD ? Icons.attach_money : Icons.currency_exchange,
              color: AppTheme.primaryGold,
            ),
            tooltip: "تغيير العملة (USD / IQD)",
            onPressed: () => carProvider.toggleCurrency(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.primaryGold),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const FilterModal(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Iraqi Governorate Selector & Quick Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              color: AppTheme.cardDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.accentBlue, size: 20),
                      const SizedBox(width: 6),
                      const Text("المحافظة: ", style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryDark)),
                      DropdownButton<String>(
                        value: carProvider.selectedGovernorate,
                        dropdownColor: AppTheme.cardDark,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGold),
                        items: governorates.map((gov) {
                          return DropdownMenuItem(
                            value: gov,
                            child: Text(
                              gov,
                              style: const TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) carProvider.setGovernorate(val);
                        },
                      ),
                      const Spacer(),
                      Text(
                        carProvider.showInUSD ? "العرض بالدولار \$" : "العرض بالدينار د.ع",
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Search Bar Input
                  TextField(
                    onChanged: (val) => carProvider.setSearchQuery(val),
                    style: const TextStyle(color: AppTheme.textPrimaryDark),
                    decoration: InputDecoration(
                      hintText: "ابحث بالماركة، الموديل، أو المحافظة... (مثلاً النترا 2023)",
                      hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold),
                      filled: true,
                      fillColor: AppTheme.darkBackground,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorderDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.cardBorderDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primaryGold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Brand Selector Chips
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = carProvider.selectedBrand == brand;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(brand),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryGold,
                      backgroundColor: AppTheme.cardDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) carProvider.setBrand(brand);
                      },
                    ),
                  );
                },
              ),
            ),

            // Car Listings Grid / List
            Expanded(
              child: carProvider.filteredCars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car_outlined, size: 64, color: AppTheme.textSecondaryDark),
                          const SizedBox(height: 12),
                          const Text("لا توجد سيارات تطابق الفلترة الحالية", style: TextStyle(color: AppTheme.textSecondaryDark)),
                          TextButton(
                            onPressed: () => carProvider.resetFilters(),
                            child: const Text("إعادة عرض جميع الإعلانات", style: TextStyle(color: AppTheme.primaryGold)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: carProvider.filteredCars.length,
                      itemBuilder: (context, index) {
                        final car = carProvider.filteredCars[index];
                        final isFav = carProvider.isFavorite(car.id);

                        return GestureDetector(
                          onTap: () {
                            carProvider.trackCarAction(car.id, 'view');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CarDetailsScreen(carId: car.id)),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: car.isVIP ? AppTheme.primaryGold : AppTheme.cardBorderDark,
                                width: car.isVIP ? 2 : 1,
                              ),
                              boxShadow: car.isVIP
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryGold.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Car Image Stack with Badges
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          car.images.isNotEmpty ? car.images.first : '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: Colors.grey.shade900,
                                            child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // VIP Highlight Badge
                                    if (car.isVIP)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.workspace_premium, color: Colors.black, size: 14),
                                              SizedBox(width: 4),
                                              Text(
                                                "CarZ VIP",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    // Media Badge Indicators (Photos count + Video tag)
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                                                const SizedBox(width: 4),
                                                Text("${car.images.length}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          if (car.videoUrl.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.play_circle_fill, color: Colors.white, size: 12),
                                                  SizedBox(width: 4),
                                                  Text("فيديو قصير", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Heart Favorite Button
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        radius: 18,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            isFav ? Icons.favorite : Icons.favorite_border,
                                            color: isFav ? Colors.redAccent : Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () => carProvider.toggleFavorite(car.id),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Car Text Details & Price
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              car.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimaryDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.darkBackground,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "${car.year}",
                                              style: const TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Price formatting (USD / IQD)
                                      Row(
                                        children: [
                                          Text(
                                            carProvider.showInUSD
                                                ? "\$${car.priceUSD.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}"
                                                : "${(car.priceIQD / 1000000).toStringAsFixed(1)} مليون د.ع",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryGold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            carProvider.showInUSD
                                                ? "(${(car.priceIQD / 1000000).toStringAsFixed(1)} مليون د.ع)"
                                                : "(\$${car.priceUSD.toStringAsFixed(0)})",
                                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Specs row: Mileage, Governorate, Transmission, Seller Stars
                                      Row(
                                        children: [
                                          const Icon(Icons.speed, size: 14, color: AppTheme.textSecondaryDark),
                                          const SizedBox(width: 4),
                                          Text("${car.mileage.toInt()} كم", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondaryDark),
                                          const SizedBox(width: 4),
                                          Text(car.governorate, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
                                          const Spacer(),
                                          // Seller star rating badge
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 14, color: Colors.amber),
                                              const SizedBox(width: 2),
                                              Text(
                                                "${car.sellerRating}",
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
