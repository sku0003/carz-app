const mongoose = require('mongoose');

const carSchema = new mongoose.Schema({
  title: { type: String, required: true },
  brand: { type: String, required: true }, // تويوتا, هيونداي, كيا, دوج, نيسان...
  model: { type: String, required: true }, // لاندكروزر, النترا, سورينتو, تشارجر...
  year: { type: Number, required: true },
  priceUSD: { type: Number, required: true },
  priceIQD: { type: Number, required: true },
  mileage: { type: Number, required: true }, // كم
  transmission: { type: String, default: 'أوتوماتيك' }, // أوتوماتيك / عادي
  fuelType: { type: String, default: 'بنزين' }, // بنزين / هجين / كهربائي
  color: { type: String, default: 'أبيض' },
  governorate: { type: String, required: true }, // بغداد, أربيل, البصرة, السليمانية, الموصل, إلخ
  specsOrigin: { type: String, default: 'وارد أمريكي' }, // وارد أمريكي / وارد خليجي / وارد كندي / وكالة
  condition: { type: String, default: 'ممتازة' },
  description: { type: String, default: '' },
  images: [{ type: String }],
  videoUrl: { type: String, default: '' },
  isVIP: { type: Boolean, default: false },
  vipExpiresAt: { type: Date },
  sellerId: { type: String, required: true },
  sellerName: { type: String, required: true },
  sellerPhone: { type: String, required: true },
  sellerWhatsApp: { type: String, required: true },
  sellerRating: { type: Number, default: 4.8 },
  sellerReviewCount: { type: Number, default: 12 },
  viewsCount: { type: Number, default: 0 },
  whatsappClicks: { type: Number, default: 0 },
  callClicks: { type: Number, default: 0 },
  chatStarts: { type: Number, default: 0 },
  priceHistory: [
    {
      priceUSD: Number,
      date: { type: Date, default: Date.now }
    }
  ],
  status: { type: String, enum: ['active', 'sold', 'archived'], default: 'active' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Car', carSchema);
