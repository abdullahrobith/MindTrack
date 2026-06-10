import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {

  final email = ''.obs;
  final password = ''.obs;

  final globalAuth =
      Get.find<GlobalAuthController>();

  RxBool isLoading = false.obs;

  Future<void> login() async {
    try {
      isLoading.value = true;

      await globalAuth.login(
        email: email.value.trim(),
        password: password.value.trim(),
      );

      final user = globalAuth.currentUser.value;
      if (user != null && !user.isVerified) {
        Get.offAllNamed(Routes.VERIFICATION);
      } else if (user != null) {
        Get.offAllNamed(Routes.BERANDA);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      await globalAuth.loginWithGoogle();
      Get.offAllNamed(Routes.BERANDA);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (email.value.trim().isEmpty) {
      Get.snackbar('Error', 'Silakan isi email terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;
      await globalAuth.forgotPassword(email: email.value.trim());
      Get.snackbar(
        'Berhasil', 
        'Link reset password telah dikirim ke email Anda jika terdaftar',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }
}