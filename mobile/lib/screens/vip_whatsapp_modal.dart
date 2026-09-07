import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class VipWhatsAppModal extends StatelessWidget {
  final String carTitle;
  final String whatsappNumber = "+966562514125";
  final String whatsappIntlPhone = "966562514125";

  const VipWhatsAppModal({Key? key, required this.carTitle}) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: whatsappNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم نسخ رقم الواتساب (+966562514125) بنجاح!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final msg = Uri.encodeComponent("مرحباً، أرغب بترقية إعلاني في تطبيق CarZ إلى VIP المميز:\n$carTitle");
    final Uri url = Uri.parse("https://wa.me/$whatsappIntlPhone?text=$msg");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فتح المحادثة عبر واتساب: $whatsappNumber")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.vipGradientStart, AppTheme.vipGradientEnd],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.black, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ترقية الإعلان إلى CarZ VIP",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        Text(
                          "احصل على أعلى معدل مشاهدات وتواصل مباشر في العراق!",
                          style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Benefits Breakdown List
            const Text(
              "مميزات الإعلان المميز CarZ VIP:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 10),
            _buildBenefitItem(Icons.star, "يظهر في أعلى القائمة الرئيسية CarZ Carousel"),
            _buildBenefitItem(Icons.palette, "إطار ورسم ذهبي براق يميز إعلانك عن باقي السيارات"),
            _buildBenefitItem(Icons.verified, "شارة تمييز موثقة ترفع ثقة المشتري وتضاعف المشاهدات 5X"),
            _buildBenefitItem(Icons.bolt, "تنبيهات فورية للمشترين المهتمين في منطقتك"),
            const SizedBox(height: 20),

            // WhatsApp Contact Instruction Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.whatsappGreen.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, color: AppTheme.whatsappGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "للترقية، تواصل معنا عبر الواتساب:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    whatsappNumber,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.whatsappGreen,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "بعد تحويل المبلغ يدوياً، سيقوم المشرف بتفعيل VIP فورياً لإعلانك.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons (Copy & Direct WhatsApp)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.cardBorderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: const Text("نسخ الرقم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => _copyToClipboard(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.whatsappGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text("فتح واتساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => _openWhatsApp(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimaryDark)),
          ),
        ],
      ),
    );
  }
}
