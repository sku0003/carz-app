import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../providers/car_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final String carId;

  const CarDetailsScreen({Key? key, required this.carId}) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final car = carProvider.cars.firstWhere((c) => c.id == widget.carId);

    if (car.videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(car.videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone, CarProvider provider) async {
    provider.trackCarAction(widget.carId, 'call');
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("جاري الاتصال على الرقم: $phone")),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String title, CarProvider provider) async {
    provider.trackCarAction(widget.carId, 'whatsapp');
    final cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    final msg = Uri.encodeComponent("مرحباً، أنا مهتم بإعلانك على تطبيق CarZ:\n$title");
    final Uri url = Uri.parse("https://wa.me/$cleanPhone?text=$msg");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فتح المحادثة عبر واتساب: $cleanPhone")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final car = carProvider.cars.firstWhere(
      (c) => c.id == widget.carId,
      orElse: () => carProvider.cars.first,
    );
    final isFav = carProvider.isFavorite(car.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(car.brand, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
            ),
            onPressed: () => carProvider.toggleFavorite(car.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gallery PageView / Short Video Player
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: car.images.length + (car.videoUrl.isNotEmpty ? 1 : 0),
                    onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                    itemBuilder: (context, index) {
                      // If last item and has video
                      if (car.videoUrl.isNotEmpty && index == car.images.length) {
                        return _isVideoInitialized
                            ? AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    VideoPlayer(_videoController!),
                                    VideoProgressIndicator(_videoController!, allowScrubbing: true),
                                    Center(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        radius: 28,
                                        child: IconButton(
                                          icon: Icon(
                                            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _videoController!.value.isPlaying
                                                  ? _videoController!.pause()
                                                  : _videoController!.play();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                                ),
                              );
                      }

                      return Image.network(
                        car.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                      );
                    },
                  ),

                  // Carousel Indicator Dots
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        car.images.length + (car.videoUrl.isNotEmpty ? 1 : 0),
                        (index) => Container(
                          width: _currentImageIndex == index ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index ? AppTheme.primaryGold : Colors.white54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CarZ VIP Badge
                  if (car.isVIP)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.workspace_premium, color: Colors.black, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "إعلان مميز CarZ VIP",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Car Header Details (Title, Price, Governorate)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price Bar USD & IQD
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("السعر المطلوب:", style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
                            Text(
                              "\$${car.priceUSD.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("بالدينار العراقي:", style: TextStyle(fontSize: 10, color: AppTheme.textSecondaryDark)),
                              Text(
                                "${(car.priceIQD / 1000000).toStringAsFixed(1)} مليون د.ع",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specifications Grid
                  const Text("المواصفات الرئيسية:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildSpecTile(Icons.calendar_today, "سنة الصنع", "${car.year}"),
                      _buildSpecTile(Icons.speed, "المسافة", "${car.mileage.toInt()} كم"),
                      _buildSpecTile(Icons.settings, "ناقل الحركة", car.transmission),
                      _buildSpecTile(Icons.local_gas_station, "نوع الوقود", car.fuelType),
                      _buildSpecTile(Icons.palette, "اللون الخارج", car.color),
                      _buildSpecTile(Icons.location_on, "المحافظة", car.governorate),
                      _buildSpecTile(Icons.public, "أصل المواصفات", car.specsOrigin),
                      _buildSpecTile(Icons.verified, "حالة السيارة", car.condition),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description Text
                  const Text("الوصف والتفاصيل:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      car.description,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textPrimaryDark),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Price History & Drop Alert Timeline
                  if (car.priceHistory.isNotEmpty) ...[
                    const Text("سجل تغير السعر والتنبيهات:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorderDark),
                      ),
                      child: Column(
                        children: car.priceHistory.map((ph) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history, size: 16, color: AppTheme.accentBlue),
                                    const SizedBox(width: 8),
                                    Text("تغيير السعر: \$${ph['priceUSD']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text("${ph['date']}", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Seller Trust Card & Rating
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryGold,
                          child: Text(
                            car.sellerName.isNotEmpty ? car.sellerName[0] : "م",
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.sellerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < car.sellerRating.floor() ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${car.sellerRating} (${car.sellerReviewCount} تقييم)",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Padding for sticky bottom action bar
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Contact Bar (Phone, WhatsApp, Internal Chat)
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppTheme.cardDark,
        child: Row(
          children: [
            // Phone Call Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.phone, color: Colors.black),
                label: const Text("اتصال", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () => _makePhoneCall(car.sellerPhone, carProvider),
              ),
            ),
            const SizedBox(width: 8),

            // WhatsApp Direct Button
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.whatsappGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.chat_bubble, color: Colors.white),
                label: const Text("واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _openWhatsApp(car.sellerWhatsApp, car.title, carProvider),
              ),
            ),
            const SizedBox(width: 8),

            // Internal Chat Button
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                padding: const EdgeInsets.all(14),
              ),
              icon: const Icon(Icons.mark_unread_chat_alt, color: Colors.black),
              tooltip: "دردشة داخلية",
              onPressed: () {
                carProvider.trackCarAction(widget.carId, 'chat');
                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                final threadId = chatProvider.startOrGetThread(
                  carId: car.id,
                  carTitle: car.title,
                  carImage: car.images.isNotEmpty ? car.images.first : '',
                  sellerName: car.sellerName,
                  sellerPhone: car.sellerPhone,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(threadId: threadId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondaryDark)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
