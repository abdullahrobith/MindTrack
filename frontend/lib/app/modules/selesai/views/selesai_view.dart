import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';

class SelesaiView extends StatelessWidget {
  const SelesaiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // 👉 set active tab ke BERANDA
    Get.find<NavigationController>().currentIndex.value = 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        title: const Text(
          "MindTrack",
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
            const Text(
              "Hampir Selesai",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Mari kita bersabar sejenak, nikmati ketenangan sejenak, melengkapi perjalanan hari ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 25),

            /// PROGRESS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("KEMAJUAN HARI", style: TextStyle(fontSize: 10)),
                Text("85% Complete", style: TextStyle(fontSize: 10)),
              ],
            ),

            const SizedBox(height: 5),

            const LinearProgressIndicator(
              value: 0.85,
              color: Color(0xFF1B434D),
              backgroundColor: Color(0xFFF1F1F1),
            ),

            const SizedBox(height: 30),

            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "https://picsum.photos/400/200",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),

            /// REFLEKSI
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Refleksi Terakhir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildRefleksiCard(
              "Apa yang membuat anda merasa paling tenang hari ini?",
              "Suasana pagi di taman belakang rumah...",
            ),

            _buildRefleksiCard(
              "Satu motivasi apa yang ingin Anda katakan sebelum tidur?",
              "Tetaplah berbuat baik apapun kondisinya...",
            ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAllNamed('/hasil');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E66E7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Selesaikan Laporan",
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

      /// ✅ NAVBAR REUSABLE
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  Widget _buildRefleksiCard(String q, String a) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            a,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}