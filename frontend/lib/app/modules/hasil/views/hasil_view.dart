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
                      "${controller.finalScore.value}",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Get.isDarkMode ? Colors.white : const Color(0xFF1B434D),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => Text(
                controller.level.value.toUpperCase(),
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
                "Status: ${controller.level.value}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : const Color(0xFF1B434D),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      Icons.analytics,
                      "Mental Score",
                      "${controller.mentalPercentage.value}%",
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _metricCard(
                      Icons.favorite,
                      "Lifestyle",
                      "${controller.lifestyleScore.value}%",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= INFO BOX =================

            Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Get.theme.textTheme.bodyLarge?.color,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _getDescription(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= METRIC =================

            // ================= INSIGHT =================

_sectionHeader(
  "INSIGHT HARI INI",
),

Obx(() => _insightItem(
  Icons.psychology,
  "Kondisi Mental",
  controller.mentalPercentage.value >= 80
      ? "Kondisi emosional Anda sangat stabil dan terkendali hari ini."
      : controller.mentalPercentage.value >= 60
          ? "Secara umum kondisi mental Anda cukup baik, namun tetap jaga keseimbangan aktivitas dan istirahat."
          : controller.mentalPercentage.value >= 40
              ? "Terdapat beberapa tanda tekanan psikologis yang perlu diperhatikan."
              : "Indikator kesehatan mental menunjukkan kondisi yang cukup berat dan membutuhkan perhatian lebih.",
)),

Obx(() => _insightItem(
  Icons.hotel,
  "Pola Tidur",
  controller.sleepHours.value >= 8
      ? "Durasi tidur Anda sangat baik dan mendukung pemulihan fisik maupun mental."
      : controller.sleepHours.value >= 6
          ? "Waktu tidur Anda cukup baik, namun masih dapat ditingkatkan."
          : "Durasi tidur Anda masih kurang dan dapat memengaruhi suasana hati serta produktivitas.",
)),

Obx(() => _insightItem(
  Icons.people,
  "Interaksi Sosial",
  controller.socialInteraction.value >= 3
      ? "Anda memiliki hubungan sosial yang aktif dan positif hari ini."
      : controller.socialInteraction.value >= 2
          ? "Interaksi sosial Anda cukup baik dan membantu menjaga kesehatan emosional."
          : "Cobalah meluangkan waktu untuk berbicara dengan keluarga atau teman terdekat.",
)),

Obx(() => _insightItem(
  Icons.trending_up,
  "Produktivitas",
  controller.productivity.value >= 3
      ? "Produktivitas Anda berada pada tingkat yang sangat baik hari ini."
      : controller.productivity.value >= 2
          ? "Aktivitas harian berjalan cukup baik dan produktif."
          : "Produktivitas hari ini masih rendah. Cobalah membuat target kecil yang realistis.",
)),

Obx(
  () => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: Get.isDarkMode 
            ? [Get.theme.cardColor, Get.theme.cardColor.withOpacity(0.8)]
            : const [
                Color(0xFFEAF4FF),
                Color(0xFFF7FBFF),
              ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: const Color(0xFF2E66E7).withOpacity(0.15),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E66E7)
                    .withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF2E66E7),
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              "Highlight Hari Ini",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Get.theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Text(
          controller.finalScore.value >= 80
              ? "Secara keseluruhan Anda berada dalam kondisi yang sangat baik, baik secara mental maupun gaya hidup."
              : controller.finalScore.value >= 60
                  ? "Kondisi Anda cukup baik. Tetap pertahankan pola hidup sehat yang sudah berjalan."
                  : controller.finalScore.value >= 40
                      ? "Beberapa aspek kesehatan mental dan gaya hidup masih perlu ditingkatkan."
                      : "Kondisi Anda memerlukan perhatian lebih. Luangkan waktu untuk pemulihan dan jangan ragu mencari dukungan.",
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Get.isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 30),

// ================= REKOMENDASI =================

            _sectionHeader(
              "REKOMENDASI UNTUK HARI INI",
            ),

            Obx(
              () => Column(
                children: controller.recommendations
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: _actionItem(
                          item["icon"],
                          item["title"],
                          item["subtitle"],
                          item["color"],
                          route: item["route"],
                        ),
                      ),
                    )
                    .toList(),
              ),
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
  switch (controller.level.value) {
    case "Sangat Baik":
      return "Kondisi Mental Sangat Baik";

    case "Baik":
      return "Kondisi Mental Baik";

    case "Sedang":
      return "Perlu Sedikit Perhatian";

    case "Kurang":
      return "Perlu Menjaga Keseimbangan";

    case "Buruk":
      return "Perlu Dukungan dan Perhatian";

    default:
      return "Hasil Assessment";
  }
}

  String _getDescription() {
  switch (controller.level.value) {
    case "Sangat Baik":
      return "Kesehatan mental dan aktivitas harian Anda berada pada kondisi yang sangat baik. Pertahankan pola hidup positif yang sudah berjalan.";

    case "Baik":
      return "Kondisi kesehatan mental Anda cukup baik. Tetap jaga kualitas tidur, aktivitas fisik, dan hubungan sosial.";

    case "Sedang":
      return "Terdapat beberapa indikator yang perlu diperhatikan. Cobalah meningkatkan aktivitas positif dan mengelola stres dengan baik.";

    case "Kurang":
      return "Beberapa aspek kesehatan mental dan aktivitas harian menunjukkan penurunan. Luangkan waktu untuk istirahat dan pemulihan.";

    case "Buruk":
      return "Hasil assessment menunjukkan kondisi yang memerlukan perhatian lebih. Pertimbangkan untuk berkonsultasi dengan tenaga profesional.";

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
          color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Get.isDarkMode ? Colors.white : const Color(0xFF1B434D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightItem(
  IconData icon,
  String title,
  String description,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Get.theme.cardColor,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [

        Icon(
          icon,
          color: const Color(0xFF2E66E7),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
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
  Color bgColor, {
  required String route,
}) {
  return InkWell(
    onTap: () {
      Get.toNamed(route);
    },
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
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
          ),
        ],
      ),
    ),
  );
}
}