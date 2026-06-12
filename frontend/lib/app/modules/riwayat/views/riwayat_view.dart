import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SET INDEX NAVBAR = 3 (Riwayat)
    Get.find<NavigationController>().currentIndex.value = 3;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'MindTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: const Icon(Icons.spa, color: Colors.white),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Get.theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Your journey towards peace and clarity, archived for your reflection.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // LIST HISTORY
            Obx(() => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.historyData.length,
                  itemBuilder: (context, index) {
                    var section = controller.historyData[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthSeparator(section['month'] as String),

                        ...(section['items'] as List)
                            .map((item) => _buildHistoryCard(item))
                            .toList(),
                      ],
                    );
                  },
                )),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // ================= MONTH SEPARATOR =================
  Widget _buildMonthSeparator(String month) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              month,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100),
        color: Get.isDarkMode ? Colors.grey.shade800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // ICON
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Text(item['icon']),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['date'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Get.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.circle,
                        size: 8, color: Colors.green),
                    const SizedBox(width: 5),
                    Text(
                      item['mood'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BUTTON
          TextButton(
            onPressed: () {
              // nanti bisa diarahkan ke detail hasil
            },
            child: const Row(
              children: [
                Text(
                  "DETAIL",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 16, color: Colors.grey),
              ],
            ),
          )
        ],
      ),
    );
  }
}