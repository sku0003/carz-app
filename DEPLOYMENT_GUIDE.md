# CarZ - دليل النشر الكامل

## الهيكل

```
carz_app/
├── mobile/          Flutter APK
├── backend/         Node.js API  
├── public_web/      الموقع الالكتروني
```

---

## 1 - نشر الموقع - Vercel (مجاني)

1. اذهب الى vercel.com وسجل دخولا بحساب GitHub
2. اضغط "Add New Project"
3. ارفع مجلد public_web/ او اربطه بـ GitHub
4. اضبط Root Directory على public_web
5. اضغط Deploy

### vercel.json (ضعه داخل public_web/):

{
  "version": 2,
  "builds": [{ "src": "index.html", "use": "@vercel/static" }],
  "routes": [{ "src": "/(.*)", "dest": "/index.html" }]
}

---

## 2 - نشر الموقع - Netlify (بديل مجاني)

1. اذهب الى netlify.com
2. اسحب مجلد public_web/ وافلته في لوحة التحكم

### netlify.toml (ضعه داخل public_web/):

[build]
  publish = "."

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

---

## 3 - نشر الخادم والموقع وAPK - Render.com (مجاني)

1. اذهب الى render.com وسجل دخولا
2. اضغط "New Web Service"
3. ارفع المستودع من المجلد الرئيسي للمشروع واضبط:
  - Root Directory: `.`
  - Build Command: `cd backend && npm install`
  - Start Command: `node backend/server.js`
  - Environment Variable: `JWT_SECRET` بقيمة سرية طويلة
  - Environment Variable: `ADMIN_PASSWORD_HASH` = bcrypt hash of the admin password
4. اضغط Deploy
5. ستحصل على رابط مثل: https://carz-backend.onrender.com

### ربط الموقع بالخادم

في `public_web/index.html` غيّر قيمة `window.CARZ_API_BASE` قبل النشر إلى رابط خدمة Render:

```html
<script>window.CARZ_API_BASE = 'https://YOUR-BACKEND.onrender.com';</script>
```

ضع السطر قبل كود التطبيق في الصفحة. عند تشغيل الموقع من نفس خادم Node يمكن تركه فارغاً، أما Vercel وNetlify فيحتاجان رابط Render صريحاً.

---

## 4 - رفع APK للتحميل

APK النهائي موجود في:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

ونسخة التحميل الخاصة بالموقع موجودة في:
`public_web/download/carz.apk`

لربط APK المنشور بعنوان Render الحقيقي، أعد البناء بعد نشر الخادم:

```bash
flutter build apk --release --dart-define=CARZ_API_URL=https://YOUR-BACKEND.onrender.com
```

خيارات الرفع:
- Google Drive: ارفعه واجعله قابلا للمشاركة
- GitHub Releases: انشئ Release جديد وارفق الـ APK
- Telegram: ارسله عبر قناة

---

## 5 - المصادقة والبيانات

- التسجيل والدخول في الموقع والتطبيق يستخدمان نفس `/api/auth/register` و`/api/auth/login`.
- الإعلانات محفوظة في `backend/data/store.json` وتبدأ القائمة فارغة في التثبيت الجديد.
- يجب ضبط `JWT_SECRET` و`DATA_ENCRYPTION_KEY` و`ADMIN_PASSWORD_HASH` و`ADMIN_TOTP_SECRET` في Render. لا تضع القيم نفسها في Git.
- نشر الإعلان يتطلب حساباً وخمس صور على الأقل.
- شغّل `npm run backup` يومياً عبر Cron أو Scheduled Job لنسخ بيانات المنصة احتياطياً.
- استخدم جداراً نارياً على الخادم وافتح HTTPS فقط، ولا تضع مفاتيح Twilio أو JWT في Git.

## 6 - معلومات التطبيق

رقم واتساب: +966562514125
لوحة الأدمن تتطلب كلمة مرور bcrypt ورمز TOTP من تطبيق مصادقة.
الحد الادنى للصور: 5 صور
الحد الاقصى للصور: 15 صورة
مدة الفيديو: 30 ثانية
VIP عبر: واتساب يدوي
