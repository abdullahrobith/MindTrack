import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HasilController extends GetxController {

  // Detail Assessment
  final phqScore = 0.obs;
  final gadScore = 0.obs;
  final stressScore = 0.obs;

  // Score Utama
  final mentalPercentage = 0.obs;
  final lifestyleScore = 0.obs;
  final finalScore = 0.obs;

  // Kategori Akhir
  final level = ''.obs;

  // Data Aktivitas Harian
  final sleepHours = 0.0.obs;
  final socialInteraction = 0.obs;
  final productivity = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final data = Get.arguments ?? {};

    print("DATA HASIL:");
    print(data);

    phqScore.value =
        (data["phq_score"] ?? 0);

    gadScore.value =
        (data["gad_score"] ?? 0);

    stressScore.value =
        (data["stress_score"] ?? 0);

    mentalPercentage.value =
        (data["mental_percentage"] ?? 0);

    lifestyleScore.value =
        (data["lifestyle_score"] ?? 0);

    finalScore.value =
        (data["final_score"] ?? 0);

    level.value =
        data["level"] ?? "-";

    sleepHours.value =
        (data["sleep_hours"] ?? 0).toDouble();

    socialInteraction.value =
        (data["social_interaction"] ?? 0);

    productivity.value =
        (data["productivity"] ?? 0);
  }

  int get totalAssessmentScore =>
      phqScore.value +
      gadScore.value +
      stressScore.value;

  List<Map<String, dynamic>> get recommendations {
  List<Map<String, dynamic>> items = [];

  // =====================
  // STRESS TINGGI
  // =====================
  if (stressScore.value >= 10) {
    items.add({
      "title": "Latihan Pernapasan",
      "subtitle":
          "Membantu menenangkan pikiran dan mengurangi stres.",
      "icon": Icons.air,
      "route": "/breathing",
      "color": Colors.green.shade50,
    });
  }

  // =====================
  // GEJALA DEPRESI TINGGI
  // =====================
  if (phqScore.value >= 8) {
    items.add({
      "title": "Jurnal Harian",
      "subtitle":
          "Tuliskan pikiran dan perasaan Anda hari ini.",
      "icon": Icons.menu_book,
      "route": "/journal",
      "color": Colors.orange.shade50,
    });
  }

  // =====================
  // TIDUR KURANG
  // =====================
  if (sleepHours.value < 6) {
    items.add({
      "title": "Musik Relaksasi",
      "subtitle":
          "Bantu tubuh dan pikiran lebih rileks sebelum beristirahat.",
      "icon": Icons.music_note,
      "route": "/relaxation_music",
      "color": Colors.blue.shade50,
    });
  }

  // =====================
  // INTERAKSI SOSIAL RENDAH
  // =====================
  if (socialInteraction.value <= 1) {
    items.add({
      "title": "Daily Affirmation",
      "subtitle":
          "Bangun kembali rasa percaya diri dan energi positif.",
      "icon": Icons.favorite,
      "route": "/affirmation",
      "color": Colors.pink.shade50,
    });
  }

  // =====================
  // PRODUKTIVITAS RENDAH
  // =====================
  if (productivity.value <= 1) {
    items.add({
      "title": "Daily Affirmation",
      "subtitle":
          "Tingkatkan motivasi untuk menjalani aktivitas hari ini.",
      "icon": Icons.bolt,
      "route": "/affirmation",
      "color": Colors.purple.shade50,
    });
  }

  // =====================
  // KONDISI SANGAT BAIK
  // =====================
  if (items.isEmpty) {
    items.add({
      "title": "Jurnal Syukur",
      "subtitle":
          "Catat hal-hal positif yang Anda alami hari ini.",
      "icon": Icons.auto_stories,
      "route": "/journal",
      "color": Colors.lightBlue.shade50,
    });

    items.add({
      "title": "Daily Affirmation",
      "subtitle":
          "Pertahankan energi positif dan mindset yang sehat.",
      "icon": Icons.favorite,
      "route": "/affirmation",
      "color": Colors.pink.shade50,
    });
  }

  return items.take(3).toList();
}
}