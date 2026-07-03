import 'package:get/get.dart';

// Pastikan path import ini sesuai dengan struktur folder Anda
import '../controllers/riwayat_controller.dart';

class RiwayatBinding extends Bindings {
  @override
  void dependencies() {
    // Menghubungkan Controller ke View saat halaman dibuka
    Get.put<RiwayatController>(
      RiwayatController(),
      permanent: true,
    );
  }
}