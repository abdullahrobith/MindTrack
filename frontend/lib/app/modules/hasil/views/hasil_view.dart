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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Hasil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // 1. Score Circle
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4A6B5F), width: 8),
                ),
                child: Center(
                  child: Obx(() => Text(
                    "${controller.score.value}",
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(controller.stressLevel.value, 
                style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2))),
            const SizedBox(height: 5),
            Obx(() => Text("Current Status: ${controller.status.value}", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            
            const SizedBox(height: 25),

            // 2. Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFF3F7FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Everything looks okay!", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Text(
                    "Your results suggest a healthy emotional balance. While there are slight indicators of temporary stress, your resilience remains high. This is a great time to lean into preventive self-care to maintain this stability.",
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 3. Metric Breakdown
            _sectionHeader("METRIC BREAKDOWN"),
            Row(
              children: [
                Expanded(child: _metricCard(Icons.nights_stay_outlined, "Sleep Quality", "Good")),
                const SizedBox(width: 15),
                Expanded(child: _metricCard(Icons.sentiment_satisfied_alt, "Mood Stability", "High")),
              ],
            ),

            const SizedBox(height: 30),

            // 4. Next Steps
            _sectionHeader("NEXT STEPS FOR YOU"),
            _actionItem(Icons.spa_outlined, "5-min Breathing Exercise", "Quickly reduce cortisol levels", Colors.green.shade50),
            const SizedBox(height: 12),
            _actionItem(Icons.edit_note_outlined, "Journal Your Thoughts", "Externalize feelings through writing", Colors.blue.shade50),
            
            const SizedBox(height: 40),

            // 5. Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/beranda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E66E7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _metricCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade200, size: 24),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String title, String subtitle, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.blueGrey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}