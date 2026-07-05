import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../routes/app_pages.dart';

class FaceRegisterController extends GetxController {
  final GlobalAuthController _globalAuth = Get.find<GlobalAuthController>();

  Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  RxBool isCameraInitialized = false.obs;
  RxBool isLoading = false.obs;
  RxBool isCaptured = false.obs;
  RxString capturedImageBase64 = RxString('');
  RxString statusText = RxString('Arahkan wajah ke kamera');
  Rx<Color> statusColor = const Color(0xFFFFF176).obs;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        statusText.value = 'Tidak ada kamera tersedia';
        statusColor.value = const Color(0xFFEF5350);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      cameraController.value = controller;
      isCameraInitialized.value = true;
    } catch (e) {
      statusText.value = 'Gagal mengakses kamera';
      statusColor.value = const Color(0xFFEF5350);
    }
  }

  Future<void> capture() async {
    if (cameraController.value == null || !isCameraInitialized.value) return;

    try {
      isLoading.value = true;
      statusText.value = 'Memproses...';
      statusColor.value = const Color(0xFFFFF176);

      final XFile photo = await cameraController.value!.takePicture();
      final File file = File(photo.path);
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      capturedImageBase64.value = base64Image;
      isCaptured.value = true;
      statusText.value = 'Wajah terdeteksi!';
      statusColor.value = const Color(0xFF66BB6A);
    } catch (e) {
      statusText.value = 'Gagal mengambil foto';
      statusColor.value = const Color(0xFFEF5350);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retake() async {
    isCaptured.value = false;
    capturedImageBase64.value = '';
    statusText.value = 'Arahkan wajah ke kamera';
    statusColor.value = const Color(0xFFFFF176);
  }

  Future<void> save() async {
    if (capturedImageBase64.value.isEmpty) return;

    try {
      isLoading.value = true;
      statusText.value = 'Menyimpan wajah...';
      statusColor.value = const Color(0xFFFFF176);

      await _globalAuth.registerFace(capturedImageBase64.value);

      Get.snackbar(
        'Berhasil',
        'Wajah berhasil didaftarkan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF66BB6A),
        colorText: const Color(0xFFFFFFFF),
      );

      Get.offNamedUntil(Routes.VERIFICATION, (route) => false);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFEF5350),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> skip() async {
    Get.offNamedUntil(Routes.VERIFICATION, (route) => false);
  }

  @override
  void onClose() {
    cameraController.value?.dispose();
    super.onClose();
  }
}
