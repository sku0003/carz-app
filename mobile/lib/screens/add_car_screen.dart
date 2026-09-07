import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../providers/car_provider.dart';
import '../theme/app_theme.dart';
import 'vip_whatsapp_modal.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({Key? key}) : super(key: key);

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descController = TextEditingController();
  final _videoUrlController = TextEditingController();

  // Photo URLs list: minimum 5 required, max 15 allowed
  final List<TextEditingController> _imageControllers = [
    TextEditingController(text: "https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=1200&q=80"),
    TextEditingController(text: "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80"),
    TextEditingController(text: "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80"),
    TextEditingController(text: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1200&q=80"),
    TextEditingController(text: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=1200&q=80"),
  ];

  String _selectedBrand = 'تويوتا';
  int _selectedYear = 2024;
  String _selectedGovernorate = 'بغداد';
  String _selectedTransmission = 'أوتوماتيك';
  String _selectedFuelType = 'بنزين';
  final List<String> brands = const ['تويوتا', 'هيونداي', 'كيا', 'دوج', 'نيسان', 'جيب', 'مرسيدس', 'بي إم دبليو'];
  final List<String> governorates = const ['بغداد', 'أربيل', 'البصرة', 'السليمانية', 'الموصل', 'النجف', 'كربلاء', 'كركوك', 'بابل'];
  final List<String> transmissions = const ['أوتوماتيك', 'عادي'];
  final List<String> fuels = const ['بنزين', 'هجين', 'كهربائي', 'ديزل'];

  void _addImageField() {
    if (_imageControllers.length < 15) {
      setState(() {
        _imageControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الحد الأقصى المسموح به هو 15 صورة")),
      );
    }
  }

  void _removeImageField(int index) {
    if (_imageControllers.length > 5) {
      setState(() {
        _imageControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الحد الأدنى الإجباري للإعلان هو 5 صور على الأقل")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة إعلان سيارة جديد"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIP Promotion Offer Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.black, size: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ترقية الإعلان إلى CarZ VIP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("تواصل معنا عبر واتساب لترقية الإعلان يدوياً ومضاعفة المشاهدات 5X!", style: TextStyle(color: Colors.black87, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => VipWhatsAppModal(carTitle: _titleController.text.isNotEmpty ? _titleController.text : "إعلان سيارة"),
                        );
                      },
                      child: const Text("ترقية VIP", style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Input
              _buildLabel("عنوان الإعلان (مثلاً: تويوتا لاندكروزر VXR 2024 مكفولة):"),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppTheme.textPrimaryDark),
                decoration: _buildInputDecoration("أدخل عنواناً واضحاً ومجذباً"),
                validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال عنوان الإعلان' : null,
              ),
              const SizedBox(height: 16),

              // Brand & Governorate Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("الماركة:"),
                        DropdownButtonFormField<String>(
                          value: _selectedBrand,
                          dropdownColor: AppTheme.cardDark,
                          decoration: _buildInputDecoration(""),
                          items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                          onChanged: (val) => setState(() => _selectedBrand = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("المحافظة:"),
                        DropdownButtonFormField<String>(
                          value: _selectedGovernorate,
                          dropdownColor: AppTheme.cardDark,
                          decoration: _buildInputDecoration(""),
                          items: governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) => setState(() => _selectedGovernorate = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Model & Year Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("الموديل (الفئة):"),
                        TextFormField(
                          controller: _modelController,
                          style: const TextStyle(color: AppTheme.textPrimaryDark),
                          decoration: _buildInputDecoration("مثال: كامري / النترا"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("سنة الصنع:"),
                        DropdownButtonFormField<int>(
                          value: _selectedYear,
                          dropdownColor: AppTheme.cardDark,
                          decoration: _buildInputDecoration(""),
                          items: List.generate(26, (i) => 2025 - i).map((y) => DropdownMenuItem(value: y, child: Text("$y"))).toList(),
                          onChanged: (val) => setState(() => _selectedYear = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price & Mileage Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("السعر (\$ USD):"),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.textPrimaryDark),
                          decoration: _buildInputDecoration("مثال: 18500"),
                          validator: (val) => val == null || val.isEmpty ? 'أدخل السعر' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("المسافة (كم):"),
                        TextFormField(
                          controller: _mileageController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.textPrimaryDark),
                          decoration: _buildInputDecoration("مثال: 15000"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5 - 15 Photos Requirement Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel("صور السيارة (الحد الأدنى 5 - الأقصى 15 صورة إجبارياً):"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.primaryGold, borderRadius: BorderRadius.circular(6)),
                    child: Text("${_imageControllers.length} / 15 صور", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _imageControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text("${index + 1}.", style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _imageControllers[index],
                            style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 12),
                            decoration: _buildInputDecoration("رابط الصورة ${index + 1}"),
                          ),
                        ),
                        if (_imageControllers.length > 5)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                            onPressed: () => _removeImageField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),

              if (_imageControllers.length < 15)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_a_photo, color: AppTheme.primaryGold, size: 18),
                    label: const Text("إضافة صورة أخرى (حتى 15 صورة)", style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: _addImageField,
                  ),
                ),
              const SizedBox(height: 14),

              // Short Video (Max 30s) URL
              _buildLabel("رابط فيديو قصير للسيارة (اختياري - حد أقصى 30 ثانية):"),
              TextFormField(
                controller: _videoUrlController,
                style: const TextStyle(color: AppTheme.textPrimaryDark),
                decoration: _buildInputDecoration("ضع رابط فيديو قصير بالصوت والصورة"),
              ),
              const SizedBox(height: 16),

              // Description
              _buildLabel("وصف كامل للسيارة والحالة:"),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: AppTheme.textPrimaryDark),
                decoration: _buildInputDecoration("اكتب حالة المحرك، الايرباج، الضربات والصبغ إن وجدت..."),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Check minimum 5 photos
                      final validImages = _imageControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

                      if (validImages.length < 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("يجب إضافة 5 صور على الأقل للسيارة للإعلان الإجباري"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final price = double.tryParse(_priceController.text) ?? 20000;
                      final mileage = double.tryParse(_mileageController.text) ?? 5000;

                      final newCar = Car(
                        id: "car_${DateTime.now().millisecondsSinceEpoch}",
                        title: _titleController.text,
                        brand: _selectedBrand,
                        model: _modelController.text.isNotEmpty ? _modelController.text : _selectedBrand,
                        year: _selectedYear,
                        priceUSD: price,
                        priceIQD: price * 1500,
                        mileage: mileage,
                        transmission: _selectedTransmission,
                        fuelType: _selectedFuelType,
                        color: "أبيض",
                        governorate: _selectedGovernorate,
                        specsOrigin: "وارد أمريكي",
                        condition: "ممتازة",
                        description: _descController.text.isNotEmpty ? _descController.text : "سيارة ممتازة ومكفولة.",
                        images: validImages,
                        videoUrl: _videoUrlController.text,
                        isVIP: false,
                        sellerId: "seller_baghdad_01",
                        sellerName: "المستخدم الحالي (أنا)",
                        sellerPhone: "+966562514125",
                        sellerWhatsApp: "966562514125",
                        sellerRating: 5.0,
                        sellerReviewCount: 1,
                        viewsCount: 1,
                        whatsappClicks: 0,
                        callClicks: 0,
                        chatStarts: 0,
                        priceHistory: [{'priceUSD': price, 'date': 'اليوم'}],
                        status: "active",
                        createdAt: DateTime.now(),
                      );

                      final carProvider = Provider.of<CarProvider>(context, listen: false);
                      try {
                        await carProvider.publishCar(newCar);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم نشر الإعلان على التطبيق والموقع بنجاح!"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      _titleController.clear();
                      _priceController.clear();
                      _descController.clear();
                    }
                  },
                  child: const Text(
                    "نشر الإعلان الآن",
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryDark, fontSize: 13)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
      filled: true,
      fillColor: AppTheme.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryGold)),
    );
  }
}
