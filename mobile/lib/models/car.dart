class Car {
  final String id;
  final String title;
  final String brand;
  final String model;
  final int year;
  final double priceUSD;
  final double priceIQD;
  final double mileage;
  final String transmission;
  final String fuelType;
  final String color;
  final String governorate;
  final String specsOrigin;
  final String condition;
  final String description;
  final List<String> images;
  final String videoUrl;
  final bool isVIP;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String sellerWhatsApp;
  final double sellerRating;
  final int sellerReviewCount;
  final int viewsCount;
  final int whatsappClicks;
  final int callClicks;
  final int chatStarts;
  final List<Map<String, dynamic>> priceHistory;
  final String status;
  final DateTime createdAt;

  Car({
    required this.id,
    required this.title,
    required this.brand,
    required this.model,
    required this.year,
    required this.priceUSD,
    required this.priceIQD,
    required this.mileage,
    required this.transmission,
    required this.fuelType,
    required this.color,
    required this.governorate,
    required this.specsOrigin,
    required this.condition,
    required this.description,
    required this.images,
    required this.videoUrl,
    required this.isVIP,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerWhatsApp,
    required this.sellerRating,
    required this.sellerReviewCount,
    required this.viewsCount,
    required this.whatsappClicks,
    required this.callClicks,
    required this.chatStarts,
    required this.priceHistory,
    required this.status,
    required this.createdAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: (json['year'] ?? 2023) is int ? json['year'] : int.parse(json['year'].toString()),
      priceUSD: (json['priceUSD'] ?? 0).toDouble(),
      priceIQD: (json['priceIQD'] ?? ((json['priceUSD'] ?? 0) * 1500)).toDouble(),
      mileage: (json['mileage'] ?? 0).toDouble(),
      transmission: json['transmission'] ?? 'أوتوماتيك',
      fuelType: json['fuelType'] ?? 'بنزين',
      color: json['color'] ?? 'أبيض',
      governorate: json['governorate'] ?? 'بغداد',
      specsOrigin: json['specsOrigin'] ?? 'وارد أمريكي',
      condition: json['condition'] ?? 'ممتازة',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videoUrl: json['videoUrl'] ?? '',
      isVIP: json['isVIP'] ?? false,
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? 'معرض سيارات',
      sellerPhone: json['sellerPhone'] ?? '',
      sellerWhatsApp: json['sellerWhatsApp'] ?? '',
      sellerRating: (json['sellerRating'] ?? 4.9).toDouble(),
      sellerReviewCount: json['sellerReviewCount'] ?? 10,
      viewsCount: json['viewsCount'] ?? 0,
      whatsappClicks: json['whatsappClicks'] ?? 0,
      callClicks: json['callClicks'] ?? 0,
      chatStarts: json['chatStarts'] ?? 0,
      priceHistory: json['priceHistory'] != null 
          ? List<Map<String, dynamic>>.from(json['priceHistory'])
          : [],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'brand': brand,
      'model': model,
      'year': year,
      'priceUSD': priceUSD,
      'priceIQD': priceIQD,
      'mileage': mileage,
      'transmission': transmission,
      'fuelType': fuelType,
      'color': color,
      'governorate': governorate,
      'specsOrigin': specsOrigin,
      'condition': condition,
      'description': description,
      'images': images,
      'videoUrl': videoUrl,
      'isVIP': isVIP,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerWhatsApp': sellerWhatsApp,
      'sellerRating': sellerRating,
      'sellerReviewCount': sellerReviewCount,
      'viewsCount': viewsCount,
      'whatsappClicks': whatsappClicks,
      'callClicks': callClicks,
      'chatStarts': chatStarts,
      'priceHistory': priceHistory,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
