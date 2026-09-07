const express = require('express');
const cors = require('cors');
const http = require('http');
const path = require('path');
const fs = require('fs');
const { Server } = require('socket.io');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const validator = require('validator');
const crypto = require('crypto');
const { verifySync: verifyTotp } = require('otplib');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: false } });
const dataDir = path.join(__dirname, 'data');
const dataFile = path.join(dataDir, 'store.json');
const jwtSecret = process.env.JWT_SECRET;
const dataEncryptionKey = process.env.DATA_ENCRYPTION_KEY;
const adminPasswordHash = process.env.ADMIN_PASSWORD_HASH;
const adminTotpSecret = process.env.ADMIN_TOTP_SECRET;
const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:5000,http://localhost:5050').split(',').map(origin => origin.trim()).filter(Boolean);
const isProduction = process.env.NODE_ENV === 'production';
const otpStore = new Map();
const failedAdminAttempts = [];

if (!jwtSecret || jwtSecret.length < 32) throw new Error('JWT_SECRET must be set to a random value of at least 32 characters');
if (!dataEncryptionKey || !/^[A-Za-z0-9+/]{43}=$/.test(dataEncryptionKey)) throw new Error('DATA_ENCRYPTION_KEY must be a base64 encoded 32-byte key');
if (isProduction && (!adminPasswordHash || !adminPasswordHash.startsWith('$2'))) throw new Error('ADMIN_PASSWORD_HASH must be a bcrypt hash');
if (isProduction && !adminTotpSecret) throw new Error('ADMIN_TOTP_SECRET must be set for admin 2FA');

function readStore() {
  if (!fs.existsSync(dataFile)) return { users: [], cars: [] };
  try {
    const store = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
    store.users = (store.users || []).map(user => ({ ...user, email: decryptValue(user.email), phone: decryptValue(user.phone) }));
    store.cars = (store.cars || []).map(car => ({ ...car, sellerPhone: decryptValue(car.sellerPhone), sellerWhatsApp: decryptValue(car.sellerWhatsApp) }));
    return store;
  } catch (error) {
    console.error('Unable to read data store:', error.message);
    return { users: [], cars: [] };
  }
}

function writeStore() {
  fs.mkdirSync(dataDir, { recursive: true });
  const protectedUsers = users.map(user => ({ ...user, email: encryptValue(user.email), phone: encryptValue(user.phone) }));
  const protectedCars = sampleCars.map(car => ({ ...car, sellerPhone: encryptValue(car.sellerPhone), sellerWhatsApp: encryptValue(car.sellerWhatsApp) }));
  fs.writeFileSync(dataFile, JSON.stringify({ users: protectedUsers, cars: protectedCars }, null, 2));
}

function cleanText(value, maxLength = 500) {
  return String(value || '').replace(/[<>]/g, '').replace(/[\u0000-\u001F\u007F]/g, '').trim().slice(0, maxLength);
}

function validPassword(password) {
  return typeof password === 'string' && /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,128}$/.test(password);
}

function encryptValue(value) {
  if (!value) return '';
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', Buffer.from(dataEncryptionKey, 'base64'), iv);
  const encrypted = Buffer.concat([cipher.update(String(value), 'utf8'), cipher.final()]);
  return `enc:${iv.toString('base64')}:${cipher.getAuthTag().toString('base64')}:${encrypted.toString('base64')}`;
}

function decryptValue(value) {
  if (!value || !String(value).startsWith('enc:')) return value || '';
  const [, iv, tag, encrypted] = value.split(':');
  const decipher = crypto.createDecipheriv('aes-256-gcm', Buffer.from(dataEncryptionKey, 'base64'), Buffer.from(iv, 'base64'));
  decipher.setAuthTag(Buffer.from(tag, 'base64'));
  return Buffer.concat([decipher.update(Buffer.from(encrypted, 'base64')), decipher.final()]).toString('utf8');
}

function requireAdmin(req, res, next) {
  if (req.user?.role !== 'admin') return res.status(403).json({ success: false, message: 'صلاحيات المشرف مطلوبة' });
  next();
}

app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: allowedOrigins, methods: ['GET', 'POST'], allowedHeaders: ['Content-Type', 'Authorization'] }));
app.use(express.json({ limit: '1mb', strict: true }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, limit: 300, standardHeaders: 'draft-7', legacyHeaders: false }));
app.use((req, res, next) => {
  if (isProduction && req.headers['x-forwarded-proto'] && req.headers['x-forwarded-proto'] !== 'https') return res.status(426).json({ success: false, message: 'HTTPS مطلوب' });
  if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method) && req.headers.origin && !allowedOrigins.includes(req.headers.origin)) return res.status(403).json({ success: false, message: 'مصدر الطلب غير مسموح' });
  next();
});
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, limit: 10, message: { success: false, message: 'محاولات كثيرة، حاول لاحقاً' } });

function createToken(user) {
  return jwt.sign({ id: user.id, email: user.email, role: user.role || 'user' }, jwtSecret, { expiresIn: '30d' });
}

function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  try {
    req.user = jwt.verify(token, jwtSecret);
    next();
  } catch (error) {
    res.status(401).json({ success: false, message: 'يجب تسجيل الدخول أولاً' });
  }
}

// Serve Public Web Landing Page & Web App
const publicWebDir = path.join(__dirname, '../public_web');
app.use(express.static(publicWebDir));

// Endpoint for direct APK Download
app.get('/download/carz.apk', (req, res) => {
  const apkPath = path.join(publicWebDir, 'download', 'carz.apk');
  if (fs.existsSync(apkPath)) {
    res.download(apkPath, 'CarZ-Iraq-Release.apk');
  } else {
    res.status(200).send("جاري إكمال بناء ملف APK الخاص بـ CarZ.");
  }
});

// Persistent store starts empty: listings are created only by authenticated users.
const storedData = readStore();
let sampleCars = storedData.cars || [];
let users = storedData.users || [];

// REST API Endpoints

// 1. Get Cars with Advanced Filtering (Web + App shared)
app.get('/api/cars', (req, res) => {
  let { search, brand, governorate, minPrice, maxPrice, minYear, maxYear, fuelType, transmission, isVIP, sort } = req.query;
  let results = [...sampleCars];

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(c => 
      c.title.toLowerCase().includes(q) || 
      c.brand.toLowerCase().includes(q) || 
      c.model.toLowerCase().includes(q) ||
      c.governorate.toLowerCase().includes(q)
    );
  }

  if (brand && brand !== 'الكل') results = results.filter(c => c.brand.trim() === brand.trim());
  if (governorate && governorate !== 'الكل') results = results.filter(c => c.governorate.trim() === governorate.trim());
  if (minPrice) results = results.filter(c => c.priceUSD >= Number(minPrice));
  if (maxPrice) results = results.filter(c => c.priceUSD <= Number(maxPrice));
  if (minYear) results = results.filter(c => c.year >= Number(minYear));
  if (maxYear) results = results.filter(c => c.year <= Number(maxYear));
  if (fuelType && fuelType !== 'الكل') results = results.filter(c => c.fuelType === fuelType);
  if (transmission && transmission !== 'الكل') results = results.filter(c => c.transmission === transmission);
  if (isVIP === 'true') results = results.filter(c => c.isVIP === true);

  if (sort === 'price_asc') {
    results.sort((a, b) => a.priceUSD - b.priceUSD);
  } else if (sort === 'price_desc') {
    results.sort((a, b) => b.priceUSD - a.priceUSD);
  } else {
    results.sort((a, b) => (b.isVIP ? 1 : 0) - (a.isVIP ? 1 : 0) || new Date(b.createdAt) - new Date(a.createdAt));
  }

  res.json({ success: true, count: results.length, data: results });
});

app.post('/api/auth/register', authLimiter, async (req, res) => {
  const { name, email, password, phone } = req.body;
  if (!name || !validator.isEmail(String(email || '')) || !validPassword(password)) {
    return res.status(400).json({ success: false, message: 'أدخل بريداً صحيحاً وكلمة مرور من 8 أحرف تشمل حرفاً كبيراً وصغيراً ورقماً' });
  }
  const normalizedEmail = email.trim().toLowerCase();
  if (users.some(user => user.email === normalizedEmail)) {
    return res.status(409).json({ success: false, message: 'هذا البريد مسجل مسبقاً' });
  }
  const user = {
    id: `usr_${Date.now()}`,
    name: cleanText(name, 100),
    email: normalizedEmail,
    phone: cleanText(phone, 30),
    passwordHash: await bcrypt.hash(password, 12),
    role: 'user',
    status: 'active',
    createdAt: new Date().toISOString()
  };
  users.push(user);
  writeStore();
  res.status(201).json({ success: true, token: createToken(user), user: { id: user.id, name: user.name, email: user.email } });
});

app.post('/api/auth/login', authLimiter, async (req, res) => {
  const { email, password } = req.body;
  const user = users.find(item => item.email === String(email || '').trim().toLowerCase());
  if (!user || !(await bcrypt.compare(password || '', user.passwordHash))) {
    return res.status(401).json({ success: false, message: 'البريد أو كلمة المرور غير صحيحة' });
  }
  res.json({ success: true, token: createToken(user), user: { id: user.id, name: user.name, email: user.email } });
});

app.get('/api/auth/me', requireAuth, (req, res) => {
  const user = users.find(item => item.id === req.user.id);
  if (!user) return res.status(401).json({ success: false, message: 'الحساب غير موجود' });
  res.json({ success: true, user: { id: user.id, name: user.name, email: user.email } });
});

app.post('/api/auth/phone/request-otp', authLimiter, async (req, res) => {
  const phone = cleanText(req.body.phone, 30);
  if (!/^\+?[1-9]\d{7,14}$/.test(phone)) return res.status(400).json({ success: false, message: 'رقم الهاتف غير صحيح' });
  const existing = otpStore.get(phone);
  if (existing && existing.lockedUntil > Date.now()) return res.status(429).json({ success: false, message: 'تم قفل المحاولة مؤقتاً' });
  const code = String(crypto.randomInt(100000, 1000000));
  otpStore.set(phone, { hash: crypto.createHash('sha256').update(code).digest('hex'), expiresAt: Date.now() + 5 * 60 * 1000, attempts: 0, lockedUntil: 0 });
  if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_FROM) {
    const twilio = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    await twilio.messages.create({ body: `CarZ verification code: ${code}`, from: process.env.TWILIO_FROM, to: phone });
  } else if (isProduction) {
    otpStore.delete(phone);
    return res.status(503).json({ success: false, message: 'خدمة التحقق غير مهيأة' });
  } else {
    console.log(`Development OTP for ${phone}: ${code}`);
  }
  res.json({ success: true, message: 'تم إرسال رمز التحقق' });
});

app.post('/api/auth/phone/verify-otp', authLimiter, async (req, res) => {
  const phone = cleanText(req.body.phone, 30);
  const code = cleanText(req.body.code, 6);
  const record = otpStore.get(phone);
  if (!record || record.lockedUntil > Date.now() || record.expiresAt < Date.now()) return res.status(401).json({ success: false, message: 'رمز التحقق منتهي أو غير صالح' });
  const hash = crypto.createHash('sha256').update(code).digest('hex');
  if (hash !== record.hash) {
    record.attempts += 1;
    if (record.attempts >= 3) record.lockedUntil = Date.now() + 10 * 60 * 1000;
    return res.status(401).json({ success: false, message: record.attempts >= 3 ? 'تم قفل المحاولة لمدة 10 دقائق' : 'رمز التحقق غير صحيح' });
  }
  otpStore.delete(phone);
  let user = users.find(item => item.phone === phone);
  if (!user) {
    user = { id: `usr_${Date.now()}`, name: phone, email: `${phone.replace(/\D/g, '')}@phone.carz.local`, phone, passwordHash: '', role: 'user', status: 'active', createdAt: new Date().toISOString() };
    users.push(user);
    writeStore();
  }
  res.json({ success: true, token: createToken(user), user: { id: user.id, name: user.name, email: user.email } });
});

// 2. Post Car Listing (Unified for Web & App)
app.post('/api/cars', requireAuth, (req, res) => {
  if (!req.body.title || !Number(req.body.priceUSD) || !Array.isArray(req.body.images) || req.body.images.filter(Boolean).length < 5) {
    return res.status(400).json({ success: false, message: 'العنوان والسعر وخمس صور حقيقية مطلوبة' });
  }
  const newCar = {
    id: "car_" + Date.now(),
    title: cleanText(req.body.title, 120),
    brand: cleanText(req.body.brand, 40) || "تويوتا",
    model: cleanText(req.body.model, 60) || "كورولا",
    year: Number(req.body.year) || 2024,
    priceUSD: Number(req.body.priceUSD) || 15000,
    priceIQD: (Number(req.body.priceUSD) || 15000) * 1500,
    mileage: Number(req.body.mileage) || 10000,
    transmission: req.body.transmission || "أوتوماتيك",
    fuelType: req.body.fuelType || "بنزين",
    color: req.body.color || "أبيض",
    governorate: req.body.governorate || "بغداد",
    specsOrigin: req.body.specsOrigin || "وارد أمريكي",
    condition: req.body.condition || "ممتازة",
    description: cleanText(req.body.description, 2000),
    images: Array.isArray(req.body.images) ? req.body.images.filter(Boolean) : [],
    videoUrl: validator.isURL(String(req.body.videoUrl || ''), { protocols: ['https'], require_protocol: true }) ? req.body.videoUrl : "",
    isVIP: req.body.isVIP || false,
    sellerId: req.user.id,
    sellerName: users.find(user => user.id === req.user.id)?.name || "مستخدم حقيقي",
    sellerPhone: req.body.sellerPhone || "+966562514125",
    sellerWhatsApp: "966562514125",
    sellerRating: 5.0,
    sellerReviewCount: 1,
    viewsCount: 1,
    whatsappClicks: 0,
    callClicks: 0,
    chatStarts: 0,
    priceHistory: [{ priceUSD: Number(req.body.priceUSD) || 15000, date: new Date().toISOString() }],
    status: "active",
    createdAt: new Date().toISOString()
  };

  sampleCars.unshift(newCar);
  writeStore();
  res.status(201).json({ success: true, data: newCar });
});

// Admin Authentication & Manual VIP Toggle
app.post('/api/admin/login', authLimiter, (req, res) => {
  const { password, code } = req.body;
  const totpValid = !adminTotpSecret || (typeof code === 'string' && verifyTotp({ token: code, secret: adminTotpSecret }));
  if (adminPasswordHash && typeof password === 'string' && bcrypt.compareSync(password, adminPasswordHash) && totpValid) {
    return res.json({ success: true, token: jwt.sign({ id: 'admin', role: 'admin' }, jwtSecret, { expiresIn: '15m' }) });
  }
  const attempt = JSON.stringify({ at: new Date().toISOString(), ip: req.ip }) + '\n';
  failedAdminAttempts.push(attempt);
  fs.mkdirSync(dataDir, { recursive: true });
  fs.appendFileSync(path.join(dataDir, 'security.log'), attempt);
  return res.status(401).json({ success: false, message: 'كلمة السر غير صحيحة' });
});

app.post('/api/admin/cars/:id/toggle-vip', requireAuth, requireAdmin, (req, res) => {
  const car = sampleCars.find(c => c.id === req.params.id);
  if (!car) return res.status(404).json({ success: false, message: 'السيارة غير موجودة' });
  car.isVIP = !car.isVIP;
  res.json({ success: true, message: car.isVIP ? 'تم تفعيل VIP بنجاح!' : 'تم إلغاء VIP', isVIP: car.isVIP });
});

app.get('/api/admin/stats', requireAuth, requireAdmin, (req, res) => {
  res.json({
    success: true,
    data: {
      totalUsers: users.length,
      totalCars: sampleCars.length,
      vipCars: sampleCars.filter(c => c.isVIP).length,
      totalViews: sampleCars.reduce((acc, c) => acc + c.viewsCount, 0),
      users: users.map(user => ({ id: user.id, name: user.name, email: user.email, phone: user.phone, status: user.status, createdAt: user.createdAt })),
      cars: sampleCars
    }
  });
});

// Socket connection
io.on('connection', (socket) => {
  socket.on('join_chat', (chatId) => socket.join(chatId));
  socket.on('send_message', (data) => io.to(data.chatId).emit('receive_message', data));
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`🚀 CarZ Web Platform & Server running at http://localhost:${PORT}`);
  console.log(`📥 Download APK available at http://localhost:${PORT}/download/carz.apk`);
});
