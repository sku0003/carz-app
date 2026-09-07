import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/car.dart';
import '../services/auth_api.dart';

class CarProvider with ChangeNotifier {
  List<Car> _cars = [];
  List<String> _favoriteIds = [];
  bool _isLoading = false;

  // Filter States
  String _searchQuery = '';
  String _selectedBrand = 'الكل';
  String _selectedGovernorate = 'الكل';
  double _minPrice = 0;
  double _maxPrice = 200000;
  int _minYear = 2000;
  int _maxYear = 2025;
  String _selectedFuelType = 'الكل';
  String _selectedTransmission = 'الكل';
  bool _vipOnly = false;
  String _sortBy = 'vip'; // 'vip', 'newest', 'price_asc', 'price_desc'
  bool _showInUSD = true; // USD ($) vs IQD (د.ع)

  CarProvider() {
    // Starts completely empty - No Dummy Ads!
    _cars = [];
    loadCars();
  }

  static const String _apiBaseUrl = String.fromEnvironment(
    'CARZ_API_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  Future<void> loadCars() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/api/cars'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _cars = (body['data'] as List<dynamic>)
            .map((item) => Car.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // The empty state remains visible while the API is unavailable.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> publishCar(Car car) async {
    final token = await AuthApi.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('يجب تسجيل الدخول قبل نشر الإعلان');
    }

    final response = await http.post(
      Uri.parse('$_apiBaseUrl/api/cars'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(car.toJson()),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'تعذر نشر الإعلان على الخادم');
    }

    final publishedCar = Car.fromJson(body['data'] as Map<String, dynamic>);
    _cars.removeWhere((item) => item.id == publishedCar.id);
    _cars.insert(0, publishedCar);
    notifyListeners();
  }

  List<Car> get cars => _cars;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;
  String get selectedBrand => _selectedBrand;
  String get selectedGovernorate => _selectedGovernorate;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  int get minYear => _minYear;
  int get maxYear => _maxYear;
  String get selectedFuelType => _selectedFuelType;
  String get selectedTransmission => _selectedTransmission;
  bool get vipOnly => _vipOnly;
  String get sortBy => _sortBy;
  bool get showInUSD => _showInUSD;

  // VIP cars list
  List<Car> get vipCars => _cars.where((c) => c.isVIP).toList();

  // Filtered cars list according to active filters
  List<Car> get filteredCars {
    return _cars.where((car) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = car.title.toLowerCase().contains(q) ||
            car.brand.toLowerCase().contains(q) ||
            car.model.toLowerCase().contains(q) ||
            car.governorate.toLowerCase().contains(q);
        if (!match) return false;
      }

      if (_selectedBrand != 'الكل' && car.brand.trim() != _selectedBrand.trim()) {
        return false;
      }

      if (_selectedGovernorate != 'الكل' && car.governorate.trim() != _selectedGovernorate.trim()) {
        return false;
      }

      if (car.priceUSD < _minPrice || car.priceUSD > _maxPrice) {
        return false;
      }

      if (car.year < _minYear || car.year > _maxYear) {
        return false;
      }

      if (_selectedFuelType != 'الكل' && car.fuelType != _selectedFuelType) {
        return false;
      }

      if (_selectedTransmission != 'الكل' && car.transmission != _selectedTransmission) {
        return false;
      }

      if (_vipOnly && !car.isVIP) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'price_asc') return a.priceUSD.compareTo(b.priceUSD);
        if (_sortBy == 'price_desc') return b.priceUSD.compareTo(a.priceUSD);
        if (_sortBy == 'newest') return b.createdAt.compareTo(a.createdAt);
        if (a.isVIP && !b.isVIP) return -1;
        if (!a.isVIP && b.isVIP) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  // Favorite Cars
  List<Car> get favoriteCars => _cars.where((c) => _favoriteIds.contains(c.id)).toList();

  void toggleCurrency() {
    _showInUSD = !_showInUSD;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setBrand(String brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  void setGovernorate(String gov) {
    _selectedGovernorate = gov;
    notifyListeners();
  }

  void setFilterParams({
    required double minP,
    required double maxP,
    required int minY,
    required int maxY,
    required String fuel,
    required String trans,
    required bool vip,
    required String sort,
  }) {
    _minPrice = minP;
    _maxPrice = maxP;
    _minYear = minY;
    _maxYear = maxY;
    _selectedFuelType = fuel;
    _selectedTransmission = trans;
    _vipOnly = vip;
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedBrand = 'الكل';
    _selectedGovernorate = 'الكل';
    _minPrice = 0;
    _maxPrice = 200000;
    _minYear = 2000;
    _maxYear = 2025;
    _selectedFuelType = 'الكل';
    _selectedTransmission = 'الكل';
    _vipOnly = false;
    _sortBy = 'vip';
    notifyListeners();
  }

  void toggleFavorite(String carId) {
    if (_favoriteIds.contains(carId)) {
      _favoriteIds.remove(carId);
    } else {
      _favoriteIds.add(carId);
    }
    notifyListeners();
  }

  bool isFavorite(String carId) {
    return _favoriteIds.contains(carId);
  }

  void trackCarAction(String carId, String action) {
    final idx = _cars.indexWhere((c) => c.id == carId);
    if (idx != -1) {
      final old = _cars[idx];
      int wClicks = old.whatsappClicks;
      int cClicks = old.callClicks;
      int chats = old.chatStarts;
      int views = old.viewsCount;

      if (action == 'whatsapp') wClicks++;
      if (action == 'call') cClicks++;
      if (action == 'chat') chats++;
      if (action == 'view') views++;

      _cars[idx] = Car(
        id: old.id,
        title: old.title,
        brand: old.brand,
        model: old.model,
        year: old.year,
        priceUSD: old.priceUSD,
        priceIQD: old.priceIQD,
        mileage: old.mileage,
        transmission: old.transmission,
        fuelType: old.fuelType,
        color: old.color,
        governorate: old.governorate,
        specsOrigin: old.specsOrigin,
        condition: old.condition,
        description: old.description,
        images: old.images,
        videoUrl: old.videoUrl,
        isVIP: old.isVIP,
        sellerId: old.sellerId,
        sellerName: old.sellerName,
        sellerPhone: old.sellerPhone,
        sellerWhatsApp: old.sellerWhatsApp,
        sellerRating: old.sellerRating,
        sellerReviewCount: old.sellerReviewCount,
        viewsCount: views,
        whatsappClicks: wClicks,
        callClicks: cClicks,
        chatStarts: chats,
        priceHistory: old.priceHistory,
        status: old.status,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  void addCar(Car newCar) {
    _cars.insert(0, newCar);
    notifyListeners();
  }

  void upgradeToVIP(String carId) {
    final idx = _cars.indexWhere((c) => c.id == carId);
    if (idx != -1) {
      final old = _cars[idx];
      _cars[idx] = Car(
        id: old.id,
        title: old.title,
        brand: old.brand,
        model: old.model,
        year: old.year,
        priceUSD: old.priceUSD,
        priceIQD: old.priceIQD,
        mileage: old.mileage,
        transmission: old.transmission,
        fuelType: old.fuelType,
        color: old.color,
        governorate: old.governorate,
        specsOrigin: old.specsOrigin,
        condition: old.condition,
        description: old.description,
        images: old.images,
        videoUrl: old.videoUrl,
        isVIP: !old.isVIP, // Toggle VIP
        sellerId: old.sellerId,
        sellerName: old.sellerName,
        sellerPhone: old.sellerPhone,
        sellerWhatsApp: old.sellerWhatsApp,
        sellerRating: old.sellerRating,
        sellerReviewCount: old.sellerReviewCount,
        viewsCount: old.viewsCount,
        whatsappClicks: old.whatsappClicks,
        callClicks: old.callClicks,
        chatStarts: old.chatStarts,
        priceHistory: old.priceHistory,
        status: old.status,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }
}
