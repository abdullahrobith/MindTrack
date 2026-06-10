import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/konsultasi_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';

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
        centerTitle: false,
        title: const Text(
          'MindTrack',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.spa, color: Colors.white),
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
          Text(
            "Pelacakan Aktivitas Harian",
            style: TextStyle(fontWeight: FontWeight.bold, color: Get.theme.textTheme.bodyLarge?.color),
          ),

          const SizedBox(height: 15),

          Obx(() => _buildSlider(
                "Durasi Tidur (Jam)",
                controller.tidurDuration.value,
                (v) => controller.tidurDuration.value = v,
              )),

          const SizedBox(height: 20),

          const Text(
            "Kualitas Tidur",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          _buildMoodPicker(),

          const SizedBox(height: 20),

          const Text(
            "Beban Kerja",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          _buildChoiceChip(["Rendah", "Sedang", "Tinggi"]),

          const SizedBox(height: 30),

          _bottomButton(
            "Simpan Laporan Hari Ini",
            () => Get.toNamed('/hasil'),
          ),
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
          activeColor: const Color(0xFF2E66E7),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMoodPicker() {
    List<String> icons = ["😫", "😟", "😐", "😊"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        4,
        (i) => Obx(() => GestureDetector(
              onTap: () => controller.selectedMood.value = i,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: controller.selectedMood.value == i
                      ? const Color(0xFF2E66E7).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: controller.selectedMood.value == i
                        ? const Color(0xFF2E66E7)
                        : (Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
                  ),
                ),
                child: Text(
                  icons[i],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildChoiceChip(List<String> options) {
    return Row(
      children: options
          .map(
            (opt) => Obx(
              () => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(opt),
                  selected: controller.bebanKerja.value == opt,
                  onSelected: (_) =>
                      controller.bebanKerja.value = opt,
                  selectedColor: const Color(0xFF2E66E7),
                  labelStyle: TextStyle(
                    color: controller.bebanKerja.value == opt
                        ? Colors.white
                        : (Get.isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          )
          .toList(),
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