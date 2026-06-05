import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      if (FirebaseAuth.instance.currentUser != null && !FirebaseAuth.instance.currentUser!.emailVerified) {
        Get.offAllNamed(Routes.VERIFICATION);
      } else {
        Get.offAllNamed(Routes.BERANDA);
      }

    } catch (e) {

      Get.snackbar(
        'Error',
        e.toString(),
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
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}