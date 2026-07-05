import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/face_register_controller.dart';

class FaceRegisterView extends GetView<FaceRegisterController> {
  const FaceRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (!controller.isCameraInitialized.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Mengakses kamera...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              if (!controller.isCaptured.value)
                CameraPreview(controller.cameraController.value!)
              else
                Image.memory(
                  base64Decode(controller.capturedImageBase64.value),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [0.7, 1.0],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),

              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: () => controller.skip(),
                  child: const Text(
                    'Lewati',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),

              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: controller.statusColor.value.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        controller.statusText.value,
                        style: TextStyle(
                          color: controller.statusColor.value ==
                                  const Color(0xFFFFF176)
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Daftarkan Wajah Anda',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arahkan wajah ke kamera dan pastikan pencahayaan cukup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!controller.isCaptured.value)
                      _captureButton()
                    else
                      _actionButtons(),
                  ],
                ),
              ),

              if (controller.isLoading.value)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _captureButton() {
    return GestureDetector(
      onTap: () => controller.capture(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => controller.retake(),
          child: const Text(
            'Ulangi',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        const SizedBox(width: 40),
        ElevatedButton(
          onPressed: () => controller.save(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A66DB),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Simpan Wajah',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
