import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
        // Force refresh current user logic if needed, but Firebase auth state
        // doesn't always automatically catch emailVerified immediately without reload
        await globalAuth.getCurrentUser();
        Get.offAllNamed(Routes.BERANDA);
      } else {
        Get.snackbar('Informasi', 'Email belum diverifikasi. Silakan cek inbox Anda.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendEmail() async {
    if (cooldown.value > 0) {
      Get.snackbar('Mohon Tunggu', 'Anda dapat mengirim ulang email dalam ${cooldown.value} detik.');
      return;
    }

    isLoading.value = true;
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      Get.snackbar('Berhasil', 'Email verifikasi telah dikirim ulang.');
      
      // Start 60 second cooldown
      cooldown.value = 60;
      _startCooldown();
    } catch (e) {
      Get.snackbar('Error', e.toString());
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
