import 'package:flutter/material.dart';
import 'package:get/get.dart';

class KonsultasiController extends GetxController {
  // Toggle antara Voice (true) dan Manual (false)
  var isVoiceMode = true.obs;

  // State untuk Manual Input
  var tidurDuration = 7.5.obs;
  var selectedMood = 2.obs; // 0: Buruk, 1: Sedih, 2: Oke, 3: Senang
  var bebanKerja = "Sedang".obs;
  
  
  final jenisAktivitas = TextEditingController();
  final durasiAktivitas = TextEditingController();
  final refleksi1 = TextEditingController();
  final refleksi2 = TextEditingController();

  void switchMode(bool voice) => isVoiceMode.value = voice;
}