import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';

import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class RegisterController
    extends GetxController {

  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword =
      ''.obs;

  final globalAuth =
      Get.find<
          GlobalAuthController>();

  RxBool isLoading = false.obs;

  Future<void> register() async {

    if (name.value.trim().length < 2) {
      Get.snackbar(
        'Error',
        'Nama minimal 2 karakter',
      );
      return;
    }

    if (!EmailValidator.validate(
      email.value.trim(),
    )) {

      Get.snackbar(
        'Error',
        'Email tidak valid',
      );

      return;
    }

    if (password.value.length <
        6) {

      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
      );

      return;
    }

    if (password.value !=
        confirmPassword.value) {

      Get.snackbar(
        'Error',
        'Password tidak sama',
      );

      return;
    }

    try {

      isLoading.value = true;

      await globalAuth.register(
        name: name.value.trim(),
        email:
            email.value.trim(),
        password:
            password.value,
      );

      Get.snackbar(
        'Berhasil',
        'Cek email anda untuk verifikasi',
      );

      Get.offAllNamed(
        Routes.VERIFICATION,
      );

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