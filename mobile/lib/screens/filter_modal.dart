import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';
import '../theme/app_theme.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({Key? key}) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _priceRange;
  late RangeValues _yearRange;
  late String _fuelType;
  late String _transmission;
  late bool _vipOnly;
  late String _sortBy;

  final List<String> _fuelOptions = ['الكل', 'بنزين', 'هجين', 'كهربائي', 'ديزل'];
  final List<String> _transOptions = ['الكل', 'أوتوماتيك', 'عادي'];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CarProvider>(context, listen: false);
    _priceRange = RangeValues(provider.minPrice, provider.maxPrice);
    _yearRange = RangeValues(provider.minYear.toDouble(), provider.maxYear.toDouble());
    _fuelType = provider.selectedFuelType;
    _transmission = provider.selectedTransmission;
    _vipOnly = provider.vipOnly;
    _sortBy = provider.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorderDark,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "تصفية متقدمة للإعلانات",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<CarProvider>(context, listen: false).resetFilters();
                    Navigator.pop(context);
                  },
                  child: const Text("إعادة ضبط", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
            const Divider(color: AppTheme.cardBorderDark),

            // CarZ VIP Only Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        "إعلانات CarZ VIP المميزة فقط",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _vipOnly,
                    activeColor: Colors.black,
                    activeTrackColor: Colors.white,
                    onChanged: (val) => setState(() => _vipOnly = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Price Range Slider ($ USD)
            Text(
              "نطاق السعر (\$ USD): \$${_priceRange.start.round()} - \$${_priceRange.end.round()}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200000,
              divisions: 40,
              activeColor: AppTheme.primaryGold,
              inactiveColor: AppTheme.cardBorderDark,
              labels: RangeLabels(
                "\$${_priceRange.start.round()}",
                "\$${_priceRange.end.round()}",
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 16),

            // Year Range Slider
            Text(
              "سنة الصنع: ${_yearRange.start.round()} - ${_yearRange.end.round()}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            RangeSlider(
              values: _yearRange,
              min: 2000,
              max: 2025,
              divisions: 25,
              activeColor: AppTheme.accentBlue,
              inactiveColor: AppTheme.cardBorderDark,
              labels: RangeLabels(
                "${_yearRange.start.round()}",
                "${_yearRange.end.round()}",
              ),
              onChanged: (values) => setState(() => _yearRange = values),
            ),
            const SizedBox(height: 16),

            // Fuel Type Selection Chips
            const Text(
              "نوع الوقود:",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _fuelOptions.map((fuel) {
                final isSel = _fuelType == fuel;
                return ChoiceChip(
                  label: Text(fuel),
                  selected: isSel,
                  selectedColor: AppTheme.primaryGold,
                  backgroundColor: AppTheme.darkBackground,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : AppTheme.textPrimaryDark,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (sel) {
                    if (sel) setState(() => _fuelType = fuel);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Transmission Selection Chips
            const Text(
              "نوع القير (ناقل الحركة):",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _transOptions.map((trans) {
                final isSel = _transmission == trans;
                return ChoiceChip(
                  label: Text(trans),
                  selected: isSel,
                  selectedColor: AppTheme.primaryGold,
                  backgroundColor: AppTheme.darkBackground,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.black : AppTheme.textPrimaryDark,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (sel) {
                    if (sel) setState(() => _transmission = trans);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Apply Filter Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Provider.of<CarProvider>(context, listen: false).setFilterParams(
                    minP: _priceRange.start,
                    maxP: _priceRange.end,
                    minY: _yearRange.start.round(),
                    maxY: _yearRange.end.round(),
                    fuel: _fuelType,
                    trans: _transmission,
                    vip: _vipOnly,
                    sort: _sortBy,
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "تطبيق الفلترة الحالية",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
