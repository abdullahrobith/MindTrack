import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/beranda_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../widgets/main_bottom_nav.dart';

class BerandaView extends GetView<BerandaController> {
  const BerandaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 SET INDEX SEKALI (AMAN)
    final navC = Get.find<NavigationController>();
    if (navC.currentIndex.value != 0) {
      navC.currentIndex.value = 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 25),
            _buildWeeklyTrend(),
            const SizedBox(height: 25),

            /// 📰 HEADER ARTIKEL
            _buildArticleHeader(),
            const SizedBox(height: 10),

            /// 🔍 SEARCH
            _buildSearchBar(),
            const SizedBox(height: 20),

            /// 📚 ARTIKEL
            _buildArticleSection(),
            const SizedBox(height: 25),

            /// 🎧 FITUR RELAKSASI
            _buildQuickRelaxationGrid(),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // ================= APPBAR =================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2E66E7),
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'MindTrack',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: const Icon(Icons.spa, color: Colors.white),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 15),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF2E66E7)),
          ),
        )
      ],
    );
  }

  // ================= GREETING =================
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              'Selamat pagi, ${controller.userName.value}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B434D),
              ),
            )),
        const SizedBox(height: 8),
        const Text(
          'Mari kita luangkan waktu sejenak untuk bernapas dan memulai hari dengan ketenangan.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ringkasan Hari Ini',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Text('Senin, 22 Mei', style: TextStyle(fontSize: 10)),
              )
            ],
          ),
          const SizedBox(height: 15),
          _summaryTile(Icons.sentiment_satisfied_alt, "SUASANA HATI",
              "Sangat Tenang", Colors.green.shade50),
          const SizedBox(height: 10),
          _summaryTile(Icons.nights_stay, "KUALITAS TIDUR", "7.1 Jam",
              Colors.blue.shade50),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kemajuan Mingguan',
                  style: TextStyle(fontSize: 11)),
              Obx(() => Text(
                    '${(controller.weeklyProgress.value * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11),
                  )),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Obx(() => LinearProgressIndicator(
                  value: controller.weeklyProgress.value,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF1B434D),
                  minHeight: 8,
                )),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(
      IconData icon, String title, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  // ================= WEEKLY =================
  Widget _buildWeeklyTrend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weekly Trend',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
              child: Icon(Icons.show_chart,
                  size: 50, color: Colors.blueGrey)),
        )
      ],
    );
  }

  // ================= HEADER ARTIKEL =================
  Widget _buildArticleHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Artikel Terkait",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("Lihat Semua"),
        )
      ],
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari artikel...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= ARTIKEL =================
  Widget _buildArticleSection() {
    return Column(
      children: [
        _articleCard(
          "Morning Meditation",
          "Luangkan 10 menit untuk fokus pada pernapasan.",
          Icons.wb_sunny_outlined,
        ),
        _articleCard(
          "Evening Walk",
          "Jalan santai membantu menenangkan pikiran.",
          Icons.directions_walk,
        ),
      ],
    );
  }

  Widget _articleCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE3F2FD),
            child: Icon(icon, color: const Color(0xFF2E66E7)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text(
                  "Baca selengkapnya",
                  style: TextStyle(
                    color: Color(0xFF2E66E7),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= FITUR =================
  Widget _buildQuickRelaxationGrid() {
    final features = [
      {"title": "Meditasi", "icon": Icons.self_improvement},
      {"title": "Musik", "icon": Icons.music_note},
      {"title": "Jurnal", "icon": Icons.edit_note},
      {"title": "Pernapasan", "icon": Icons.air},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Relaksasi Cepat",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            var item = features[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData,
                      size: 30, color: const Color(0xFF2E66E7)),
                  const SizedBox(height: 10),
                  Text(item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}