import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/konsultasi_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/assessment_data.dart';

class KonsultasiView extends GetView<KonsultasiController> {
  const KonsultasiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // set index ke halaman konsultasi (index = 1)
    Get.find<NavigationController>().currentIndex.value = 1;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Konsultasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: Obx(() => controller.isVoiceMode.value
                ? _buildVoiceBody()
                : _buildManualBody()),
          ),
        ],
      ),

      // ✅ pakai reusable navbar
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Konsultasi Hari Ini",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Get.theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Mari kita mulai sesi hari ini dengan mendengarkan pikiran dalam nada suara.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),

          /// TOGGLE MODE
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Obx(() => Row(
                  children: [
                    _toggleBtn(
                      "Voice",
                      controller.isVoiceMode.value,
                      () => controller.switchMode(true),
                    ),
                    _toggleBtn(
                      "Manual",
                      !controller.isVoiceMode.value,
                      () => controller.switchMode(false),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2E66E7) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= VOICE =================
Widget _buildVoiceBody() {
  return SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: Get.height * 0.7, // biar tetap proporsional
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF2E66E7),
              child: Icon(Icons.mic, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 12),

            const Text(
              "Ketuk untuk mulai berbicara",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Merekam (0:34)",
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                "Apa satu hal yang membuat Anda merasa paling tenang hari ini?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Get.theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),

            const Spacer(),

            _bottomButton(
              "Lanjutkan",
              () => Get.toNamed('/selesai'),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ================= MANUAL =================
  Widget _buildManualBody() {
return SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "PHQ Assessment",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
        const SizedBox(height: 15),

        ...List.generate(
          phqQuestions.length,
          (index) {
            return Obx(() {
              return _buildQuestionCard(
                question: phqQuestions[index],
                value: controller.phqAnswers[index],
                onChanged: (int? v) {
                  print("PHQ[$index] = $v");

                  controller.phqAnswers[index] = v;
                  controller.phqAnswers.refresh();

                  print(controller.phqAnswers);
                },
              );
            });
          },
        ),

        const SizedBox(height: 25),

        // ================= GAD =================

        const Text(
          "GAD Assessment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        ...List.generate(
          gadQuestions.length,
          (index) {
            return Obx(() {
              return _buildQuestionCard(
                question: gadQuestions[index],
                value: controller.gadAnswers[index],
                onChanged: (int? v) {
                  controller.gadAnswers[index] = v;
                },
              );
            });
          },
        ),

        const SizedBox(height: 25),

        // ================= STRESS =================

        const Text(
          "Stress Assessment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        ...List.generate(
          stressQuestions.length,
          (index) {
            return Obx(() {
              return _buildQuestionCard(
                question: stressQuestions[index],
                value: controller.stressAnswers[index],
                onChanged: (int? v) {
                  controller.stressAnswers[index] = v;
                },
              );
            });
          },
        ),

        const SizedBox(height: 30),

        const Divider(),

        const SizedBox(height: 20),

        // ================= AKTIVITAS HARIAN =================

        const Text(
          "Aktivitas Harian",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ================= AKTIVITAS 1 =================

        Obx(
          () => _buildSlider(
            "Durasi Tidur",
            controller.sleepHours.value,
            (v) => controller.sleepHours.value = v,
          ),
        ),

        const SizedBox(height: 25),

        // ================= AKTIVITAS 2 =================

        const Text(
          "Kualitas Tidur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _buildChoiceSection(
          controller.sleepQuality,
          [
            "Sangat Buruk",
            "Buruk",
            "Cukup",
            "Baik",
            "Sangat Baik"
          ],
        ),

        const SizedBox(height: 25),

        // ================= AKTIVITAS 3 =================

        const Text(
          "Aktivitas Fisik Hari Ini",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _buildChoiceSection(
          controller.physicalActivity,
          [
            "Tidak Ada",
            "Ringan",
            "Sedang",
            "Aktif",
            "Sangat Aktif"
          ],
        ),

        const SizedBox(height: 25),

        // ================= AKTIVITAS 4 =================

        const Text(
          "Interaksi Sosial Hari Ini",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _buildChoiceSection(
          controller.socialInteraction,
          [
            "Tidak Ada",
            "Sedikit",
            "Cukup",
            "Banyak",
            "Sangat Banyak"
          ],
        ),

        const SizedBox(height: 25),

        // ================= AKTIVITAS 5 =================

        const Text(
          "Produktivitas Hari Ini",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _buildChoiceSection(
          controller.productivity,
          [
            "Sangat Rendah",
            "Rendah",
            "Sedang",
            "Tinggi",
            "Sangat Tinggi"
          ],
        ),

        const SizedBox(height: 30),

        _bottomButton(
          "Simpan Laporan Hari Ini",
          () async {

            bool isComplete =
                !controller.phqAnswers.contains(null) &&
                !controller.gadAnswers.contains(null) &&
                !controller.stressAnswers.contains(null) &&
                controller.sleepQuality.value != null &&
                controller.physicalActivity.value != null &&
                controller.socialInteraction.value != null &&
                controller.productivity.value != null;

            if (!isComplete) {
              Get.snackbar(
                "Belum Lengkap",
                "Mohon isi seluruh assessment terlebih dahulu",
              );
              return;
            }

            try {

              final result =
                  await controller.submitAssessment();

              print("HASIL DARI API:");
              print(result);
              Get.toNamed(
                '/hasil',
                arguments: result,
              );

            } catch (e) {

              Get.snackbar(
                "Error",
                e.toString(),
              );
            }
          },
        ),

        const SizedBox(height: 30),
      ],
    ),
  );
}

  Widget _buildSlider(
      String label, double val, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Get.theme.textTheme.bodyMedium?.color)),
            Text("${val.toStringAsFixed(1)} Jam", style: TextStyle(color: Get.theme.textTheme.bodyMedium?.color)),
          ],
        ),
        Slider(
          value: val,
          min: 0,
          max: 12,
          divisions: 20,
          activeColor: const Color(0xFF2E66E7),
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildQuestionCard({
  required String question,
  required int? value,
  required ValueChanged<int?> onChanged,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          RadioListTile<int>(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text(
            "Tidak Sama Sekali",
            style: TextStyle(fontSize: 13),
          ),
            value: 0,
            groupValue: value,
            onChanged: onChanged,
          ),

          RadioListTile<int>(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text(
            "Sedikit",
            style: TextStyle(fontSize: 13),
          ),
            value: 1,
            groupValue: value,
            onChanged: onChanged,
          ),

          RadioListTile<int>(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text(
            "Cukup Terasa",
            style: TextStyle(fontSize: 13),
          ),
            value: 2,
            groupValue: value,
            onChanged: onChanged,
          ),

          RadioListTile<int>(
          dense: true,
          visualDensity: VisualDensity.compact,
          title: const Text(
            "Sangat Terasa",
            style: TextStyle(fontSize: 13),
          ),
            value: 3,
            groupValue: value,
            onChanged: onChanged,
          ),

          RadioListTile<int>(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: const Text(
              "Sangat Berat",
              style: TextStyle(fontSize: 13),
            ),
            value: 4,
            groupValue: value,
            onChanged: onChanged,
          ),
        ],
      ),
    ),
  );
}

Widget _buildChoiceSection(
  Rx<int?> selected,
  List<String> options,
) {
  return Obx(
    () => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        options.length,
        (index) => ChoiceChip(
          label: Text(options[index]),
          selected: selected.value == index,
          onSelected: (_) {
            selected.value = index;
          },
        ),
      ),
    ),
  );
}

  Widget _bottomButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E66E7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
