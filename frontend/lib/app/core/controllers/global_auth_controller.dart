import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/providers/auth_provider.dart' as my_provider;
import '../models/user_model.dart';
import '../services/google_sign_in_service.dart';
import '../config/network_config.dart';

class GlobalAuthController extends GetxController {
  final my_provider.AuthProvider _provider = my_provider.AuthProvider();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isDarkMode = false.obs;
  // Email sementara setelah register (sebelum verifikasi)
  String? pendingEmail;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
    
    _storage.read(key: "isDarkMode").then((val) {
      if (val != null) {
        isDarkMode.value = val == "true";
        Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      }
    });

    GoogleSignInService.init();
  }

  Future<void> _initAuth() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      NetworkConfig.token = token;
      await getCurrentUser();
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _provider.login(email: email, password: password);
    if (NetworkConfig.token != null) {
      await _storage.write(key: 'jwt_token', value: NetworkConfig.token);
      await getCurrentUser();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String tanggalLahir,
  }) async {
    await _provider.register(
      name: name,
      email: email,
      password: password,
      gender: gender,
      tanggalLahir: tanggalLahir,
    );
    // Simpan email untuk halaman verifikasi jika gagal login
    pendingEmail = email.toLowerCase();
    
    // Auto login setelah register (karena issue timeout SMTP sudah di-fix di backend)
    await login(email: email, password: password);
  }

  Future<void> resendVerification({required String email}) async {
    await _provider.resendVerification(email);
  }

  Future<void> forgotPassword({required String email}) async {
    await _provider.forgotPassword(email);
  }

  Future<void> registerFace(String imageBase64) async {
    await _provider.registerFace(imageBase64);
  }

  Future<void> loginWithFace(String imageBase64) async {
    await _provider.loginWithFace(imageBase64);
    if (NetworkConfig.token != null) {
      await _storage.write(key: 'jwt_token', value: NetworkConfig.token);
      await getCurrentUser();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await GoogleSignInService.init();
      final idToken = await GoogleSignInService.signInAndGetIdToken();

      if (idToken == null) {
        throw Exception('Login Google dibatalkan atau gagal mendapatkan token');
      }

      print("Mengirim idToken ke backend...");
      await _provider.loginWithGoogleBackend(idToken);
      if (NetworkConfig.token != null) {
        await _storage.write(key: 'jwt_token', value: NetworkConfig.token);
        await getCurrentUser();
      }
    } catch (e) {
      print("loginWithGoogle ERROR: $e");
      rethrow;
    }
  }

  Future<void> getCurrentUser() async {
    if (NetworkConfig.token == null) {
      currentUser.value = null;
      return;
    }

    UserModel? userModel = await _provider.getCurrentUser();
    if (userModel != null) {
      currentUser.value = userModel;
      isDarkMode.value = currentUser.value?.theme == "dark";
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      await _storage.write(key: "isDarkMode", value: isDarkMode.value.toString());
    } else {
      // Token is invalid or expired
      await logout();
    }
  }

  Future<void> changeTheme(String theme) async {
    isDarkMode.value = theme == "dark";
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    await _storage.write(key: "isDarkMode", value: isDarkMode.value.toString());
    
    currentUser.update((user) {
      user?.theme = theme;
    });

    await _provider.updateProfile(theme: theme);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String gender,
    required String tanggalLahir,
    String? password,
  }) async {
    await _provider.updateProfile(
      name: name,
      email: email,
      gender: gender,
      tanggalLahir: tanggalLahir,
      password: password,
    );
    await getCurrentUser();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    NetworkConfig.token = null;
    currentUser.value = null;
    await GoogleSignInService.signOut();
  }
}