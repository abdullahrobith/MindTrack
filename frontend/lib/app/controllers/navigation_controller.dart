import 'package:get/get.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    switch (index) {
      case 0:
        Get.offAllNamed('/beranda');
        break;
      case 1:
        Get.offAllNamed('/konsultasi');
        break;
      case 2:
        Get.offAllNamed('/chatbot');
        break;
      case 3:
        Get.offAllNamed('/riwayat');
        break;
      case 4:
        Get.offAllNamed('/pengaturan');
        break;
    }
  }
}