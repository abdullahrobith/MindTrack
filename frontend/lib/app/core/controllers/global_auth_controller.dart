import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/providers/auth_provider.dart' as my_provider;
import '../models/user_model.dart';
import '../services/google_sign_in_service.dart';
import '../../routes/app_pages.dart';

class GlobalAuthController extends GetxController {
  final my_provider.AuthProvider _provider = my_provider.AuthProvider();

  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isDarkMode = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await getCurrentUser();
      } else {
        currentUser.value = null;
      }
    });

    const storage = FlutterSecureStorage();
    storage.read(key: "isDarkMode").then((val) {
      if (val != null) {
        isDarkMode.value = val == "true";
        Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      }
    });

    GoogleSignInService.init();
  }

  Future<void> login({required String email, required String password}) async {
    final response = await _provider.login(email: email, password: password);
    if (response.user != null && response.user!.emailVerified) {
      await getCurrentUser();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await GoogleSignInService.init();
      final idToken = await GoogleSignInService.signInAndGetIdToken();
      
      if (idToken == null) {
        throw Exception('Login Google dibatalkan');
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _provider.saveGoogleUserToFirestore(userCredential.user!);
        await getCurrentUser();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({required String name, required String email, required String password}) async {
    await _provider.register(name: name, email: email, password: password);
  }

  Future<void> getCurrentUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    UserModel? userModel = await _provider.getUserFromFirestore(firebaseUser.uid);
    if (userModel != null) {
      currentUser.value = userModel;
      isDarkMode.value = currentUser.value?.theme == "dark";
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      const storage = FlutterSecureStorage();
      storage.write(key: "isDarkMode", value: isDarkMode.value.toString());
    }
  }

  Future<void> changeTheme(String theme) async {
    isDarkMode.value = theme == "dark";
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    const storage = FlutterSecureStorage();
    await storage.write(key: "isDarkMode", value: isDarkMode.value.toString());
    
    currentUser.update((user) {
      user?.theme = theme;
    });

    await _provider.updateProfile(theme: theme);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String gender,
    String? password,
  }) async {
    await _provider.updateProfile(
      name: name,
      email: email,
      gender: gender,
      password: password,
    );
    await getCurrentUser();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignInService.signOut();
    currentUser.value = null;
  }
}