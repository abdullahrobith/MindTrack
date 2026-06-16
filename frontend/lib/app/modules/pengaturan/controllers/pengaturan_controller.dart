import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class PengaturanController extends GetxController {
  final GlobalAuthController auth = Get.find<GlobalAuthController>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController tanggalLahirController;
  
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxString selectedGender = "Belum dipilih".obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() {
    final user = auth.currentUser.value;

    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    tanggalLahirController = TextEditingController(text: user?.tanggalLahir ?? "");

    String gender = user?.gender ?? "Belum dipilih";
    if (!["Belum dipilih", "Pria", "Wanita", "Lainnya"].contains(gender)) {
      gender = "Belum dipilih";
    }
    selectedGender.value = gender;
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      tanggalLahirController.text = formattedDate;
    }
  }

  Future<void> saveProfile() async {
    try {
      await auth.updateProfile(
        name: nameController.text,
        email: emailController.text,
        gender: selectedGender.value,
        tanggalLahir: tanggalLahirController.text,
      );
      Get.snackbar("Berhasil", "Profile diperbarui");
      Get.back(); // Go back to settings menu after saving
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> changePassword() async {
    if (passwordController.text.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Password tidak sama");
      return;
    }

    try {
      await auth.updateProfile(
        name: nameController.text,
        email: emailController.text,
        gender: selectedGender.value,
        tanggalLahir: tanggalLahirController.text,
        password: passwordController.text,
      );
      passwordController.clear();
      confirmPasswordController.clear();
      Get.snackbar("Berhasil", "Password berhasil diubah");
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> logout() async {
    await auth.logout();
    Get.offAllNamed(Routes.AUTH);
  }
}