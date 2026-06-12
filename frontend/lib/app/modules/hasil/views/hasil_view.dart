import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hasil_controller.dart';

class HasilView extends GetView<HasilController> {
  const HasilView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Hasil Assessment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [

            // ================= SCORE =================

            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A6B5F),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      "${controller.stressScore.value}",
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B434D),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => Text(
                controller.stressLevel.value.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Obx(
              () => Text(
                "Status: ${controller.stressLevel.value}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B434D),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ================= INFO BOX =================

            Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1B434D),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _getDescription(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= METRIC =================

            _sectionHeader(
              "RINGKASAN HASIL ASSESSMENT",
            ),

            Row(
              children: [

                Expanded(
                  child: Obx(
                    () => _metricCard(
                      Icons.psychology,
                      "PHQ-9",
                      "${controller.phqScore.value}\n${controller.phqLevel.value}",
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Obx(
                    () => _metricCard(
                      Icons.health_and_safety,
                      "GAD-7",
                      "${controller.gadScore.value}\n${controller.gadLevel.value}",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Obx(
              () => _metricCard(
                Icons.warning_amber_rounded,
                "Stress",
                "${controller.stressScore.value}\n${controller.stressLevel.value}",
              ),
            ),

            const SizedBox(height: 30),

            // ================= REKOMENDASI =================

            _sectionHeader(
              "REKOMENDASI UNTUK HARI INI",
            ),

            _actionItem(
              Icons.spa_outlined,
              "Latihan Pernapasan",
              "Luangkan 5 menit untuk relaksasi",
              Colors.green.shade50,
            ),

            const SizedBox(height: 12),

            _actionItem(
              Icons.edit_note_outlined,
              "Jurnal Harian",
              "Tuliskan hal yang Anda rasakan hari ini",
              Colors.blue.shade50,
            ),

            const SizedBox(height: 12),

            _actionItem(
              Icons.self_improvement,
              "Istirahat Sejenak",
              "Berikan waktu bagi tubuh dan pikiran untuk pulih",
              Colors.orange.shade50,
            ),

            const SizedBox(height: 40),

            // ================= BUTTON =================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    Get.offAllNamed('/beranda'),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2E66E7),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (controller.stressLevel.value) {
      case "Minimal":
      case "Normal":
        return "Kondisi Anda Baik";

      case "Ringan":
        return "Tetap Jaga Keseimbangan";

      case "Sedang":
        return "Perlu Sedikit Perhatian";

      case "Berat":
        return "Prioritaskan Kesehatan Mental";

      default:
        return "Hasil Assessment";
    }
  }

  String _getDescription() {
    switch (controller.stressLevel.value) {
      case "Minimal":
      case "Normal":
        return "Hasil assessment menunjukkan kondisi mental Anda berada dalam kategori baik. Tetap pertahankan pola hidup sehat dan aktivitas positif.";

      case "Ringan":
        return "Terdapat beberapa indikasi tekanan ringan. Luangkan waktu untuk beristirahat dan melakukan aktivitas yang Anda sukai.";

      case "Sedang":
        return "Anda mengalami tingkat tekanan yang cukup terasa. Cobalah mengatur jadwal istirahat dan berbicara dengan orang terpercaya.";

      case "Berat":
        return "Hasil assessment menunjukkan tekanan yang cukup tinggi. Pertimbangkan untuk mencari bantuan profesional atau konselor.";

      default:
        return "Terima kasih telah menyelesaikan assessment hari ini.";
    }
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _metricCard(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Icon(
            icon,
            color: Colors.green.shade300,
            size: 24,
          ),

          const SizedBox(height: 10),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B434D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.blueGrey,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1B434D),
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}