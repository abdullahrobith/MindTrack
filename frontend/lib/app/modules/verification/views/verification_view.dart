import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.mark_email_unread,
              size: 100,
              color: Color(0xFF2E66E7),
            ),
            const SizedBox(height: 24),
            const Text(
              'Periksa Email Anda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Kami telah mengirimkan tautan verifikasi ke email Anda. Silakan klik tautan tersebut untuk memverifikasi akun Anda.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jika email tidak muncul di Kotak Masuk (Inbox), pastikan Anda memeriksa folder Spam atau Junk.',
                      style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.checkVerificationStatus(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF2E66E7),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Saya Sudah Verifikasi',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                )),
            const SizedBox(height: 16),
            Obx(() => OutlinedButton(
              onPressed: controller.cooldown.value > 0 ? null : () => controller.resendEmail(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: controller.cooldown.value > 0 ? Colors.grey : const Color(0xFF2E66E7)),
              ),
              child: Text(
                controller.cooldown.value > 0 
                  ? 'Kirim Ulang Email (${controller.cooldown.value}s)' 
                  : 'Kirim Ulang Email',
                style: TextStyle(
                  fontSize: 16, 
                  color: controller.cooldown.value > 0 ? Colors.grey : const Color(0xFF2E66E7)
                ),
              ),
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => controller.logout(),
              child: const Text(
                'Kembali ke Login',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
