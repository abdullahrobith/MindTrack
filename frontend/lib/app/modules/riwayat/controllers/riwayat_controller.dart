import 'package:get/get.dart';

import '../../../data/providers/assessment_provider.dart';

class RiwayatController extends GetxController {

  final provider = AssessmentProvider();

  final isLoading = true.obs;

  final histories = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {

    try {

      isLoading.value = true;

      final data =
          await provider.getHistory();

      histories.assignAll(data);

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;

    }
  }
}