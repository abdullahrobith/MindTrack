import 'package:get/get.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class VerificationController extends GetxController {
  final globalAuth = Get.find<GlobalAuthController>();
  RxBool isLoading = false.obs;
  RxInt cooldown = 0.obs;
  
  @override
  void onClose() {
    cooldown.value = 0;
    super.onClose();
  }

  Future<void> checkVerificationStatus() async {
    isLoading.value = true;
    try {
      await globalAuth.getCurrentUser();
      final user = globalAuth.currentUser.value;
      
      if (user != null && user.isVerified) {
        Get.offAllNamed(Routes.BERANDA);
      } else {
        Get.snackbar('Informasi', 'Email belum diverifikasi. Silakan cek inbox Anda dan klik link verifikasi.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendEmail() async {
    if (cooldown.value > 0) {
      Get.snackbar('Mohon Tunggu', 'Anda dapat mengirim ulang email dalam ${cooldown.value} detik.');
      return;
    }

    // Ambil email dari currentUser (jika sudah login) atau pendingEmail (setelah register)
    final email = globalAuth.currentUser.value?.email ?? globalAuth.pendingEmail;
    if (email == null || email.isEmpty) {
      Get.snackbar('Error', 'Sesi tidak valid. Silakan login ulang.');
      return;
    }

    isLoading.value = true;
    try {
      await globalAuth.resendVerification(email: email);
      Get.snackbar('Berhasil', 'Email verifikasi telah dikirim ulang. Silakan cek inbox Anda.');
      
      // Start 60 second cooldown
      cooldown.value = 60;
      _startCooldown();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void _startCooldown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (cooldown.value > 0) {
        cooldown.value--;
        _startCooldown();
      }
    });
  }

  Future<void> logout() async {
    await globalAuth.logout();
    Get.offAllNamed(Routes.AUTH);
  }
}
