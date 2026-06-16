import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/user_model.dart';
import '../../core/config/network_config.dart';

class AuthProvider {
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${NetworkConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      NetworkConfig.token = data['access_token'];
    } else {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['detail'] ?? 'Login gagal');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String tanggalLahir,
  }) async {
    final res = await http.post(
      Uri.parse('${NetworkConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'gender': gender,
        'date_of_birth': tanggalLahir,
      }),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 201) {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['detail'] ?? 'Registrasi gagal');
    }
  }

  Future<void> resendVerification(String email) async {
    final res = await http.post(
      Uri.parse('${NetworkConfig.baseUrl}/auth/resend-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['detail'] ?? 'Gagal mengirim ulang email');
    }
  }

  Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('${NetworkConfig.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['detail'] ?? 'Gagal mengirim email reset');
    }
  }

  Future<void> loginWithGoogleBackend(String idToken) async {
    final res = await http.post(
      Uri.parse('${NetworkConfig.baseUrl}/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_token': idToken,
      }),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      NetworkConfig.token = data['access_token'];
    } else {
      final errorData = jsonDecode(res.body);
      throw Exception(errorData['detail'] ?? 'Login Google gagal');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    if (NetworkConfig.token == null) return null;

    final res = await http.get(
      Uri.parse('${NetworkConfig.baseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${NetworkConfig.token}',
      },
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return UserModel.fromJson(data);
    } else {
      // Token expired or invalid
      return null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? tanggalLahir,
    String? password,
    String? theme,
  }) async {
    if (NetworkConfig.token == null) return;

    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (gender != null) data['gender'] = gender;
    if (tanggalLahir != null) data['date_of_birth'] = tanggalLahir;
    if (theme != null) data['theme'] = theme;
    
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
      data['confirm_password'] = password;
    }

    if (data.isNotEmpty) {
      final res = await http.put(
        Uri.parse('${NetworkConfig.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${NetworkConfig.token}',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        final errorData = jsonDecode(res.body);
        throw Exception(errorData['detail'] ?? 'Update profil gagal');
      }
    }
  }
}