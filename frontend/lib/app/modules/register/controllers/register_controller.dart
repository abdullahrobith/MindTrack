import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';

import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  
  final gender = 'Belum dipilih'.obs;
  final tanggalLahir = ''.obs;

  final globalAuth = Get.find<GlobalAuthController>();
  RxBool isLoading = false.obs;

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      tanggalLahir.value = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> register() async {
    if (name.value.trim().length < 2) {
      Get.snackbar('Error', 'Nama minimal 2 karakter');
      return;
    }
    if (!EmailValidator.validate(email.value.trim())) {
      Get.snackbar('Error', 'Email tidak valid');
      return;
    }
    if (gender.value == 'Belum dipilih') {
      Get.snackbar('Error', 'Pilih jenis kelamin Anda');
      return;
    }
    if (tanggalLahir.value.isEmpty) {
      Get.snackbar('Error', 'Pilih tanggal lahir Anda');
      return;
    }
    if (password.value.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter');
      return;
    }
    if (password.value != confirmPassword.value) {
      Get.snackbar('Error', 'Password tidak sama');
      return;
    }

    try {
      isLoading.value = true;
      await globalAuth.register(
        name: name.value.trim(),
        email: email.value.trim(),
        password: password.value,
        gender: gender.value,
        tanggalLahir: tanggalLahir.value,
      );

      Get.snackbar('Berhasil', 'Cek email anda untuk verifikasi');
      Get.offAllNamed(Routes.VERIFICATION);
    } catch (e) {
      Get.snackbar('Error', e.toString());
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
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}