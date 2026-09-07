import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  static const String baseUrl = String.fromEnvironment(
    'CARZ_API_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static Future<String> authenticate({
    required String email,
    required String password,
    required bool register,
    String name = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/${register ? 'register' : 'login'}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['message'] ?? 'تعذر إتمام العملية');
    }
    final token = body['token'] as String;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('carz_token', token);
    return body['user']['name'] as String;
  }

  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('carz_token');
  }

  static Future<void> requestPhoneOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/phone/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) throw Exception(body['message'] ?? 'تعذر إرسال رمز التحقق');
  }

  static Future<String> verifyPhoneOtp(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/phone/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) throw Exception(body['message'] ?? 'رمز التحقق غير صالح');
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('carz_token', body['token'] as String);
    return body['user']['name'] as String;
  }

  static Future<void> adminLogin(String password, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'password': password, 'code': code}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) throw Exception(body['message'] ?? 'تعذر تسجيل دخول المشرف');
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('carz_admin_token', body['token'] as String);
  }
}
