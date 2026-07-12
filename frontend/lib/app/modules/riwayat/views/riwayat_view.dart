import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  // 🎨 Definisikan palet warna premium di sini agar konsisten di semua widget
  static const Color colorBlue = Color(0xFF2E66E7);
  static const Color colorEmerald = Color(0xFF10B981); // Hijau meditatif
  static const Color colorCoral = Color(0xFFF43F5E);   // Merah lembut/soft coral
  static const Color colorOrange = Color(0xFFF59E0B);  // Oranye hangat

  @override
  Widget build(BuildContext context) {
    Get.find<NavigationController>().currentIndex.value = 3;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
  // Menggunakan gradien halus
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF2E66E7), Color(0xFF4A7DF0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  backgroundColor: Colors.transparent, // Transparan agar gradien terlihat
  elevation: 4, // Sedikit bayangan agar tampak modern
  shadowColor: Colors.black.withOpacity(0.2),
  centerTitle: true,
  title: const Text(
    'Riwayat Assesment', // Nama lebih personal
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      letterSpacing: 0.5,
    ),
  ),
),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorBlue),
            ),
          );
        }

        if (controller.histories.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildDevelopmentCard(),
            const SizedBox(height: 25),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "RIWAYAT TERBARU",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.histories.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(controller.histories[index], context);
              },
            ),
          ],
        );
      }),
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off_rounded,
                size: 70,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Riwayat Assessment",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Kondisi mentalmu penting dipantau. Yuk, lakukan assessment pertamamu sekarang!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentCard() {
    if (controller.histories.length < 2) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade500.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          "Belum cukup data untuk menganalisis perkembangan mentalmu saat ini.",
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
      );
    }

    final latest = controller.histories[0]["final_score"] ?? 0;
    final previous = controller.histories[1]["final_score"] ?? 0;
    final diff = latest - previous;

    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (diff > 0) {
      badgeColor = colorEmerald;
      statusText = "Meningkat";
      statusIcon = Icons.trending_up_rounded;
    } else if (diff < 0) {
      badgeColor = colorCoral; // Diturunkan ke variabel lokal
      statusText = "Menurun";
      statusIcon = Icons.trending_down_rounded;
    } else {
      badgeColor = colorOrange;
      statusText = "Stabil";
      statusIcon = Icons.trending_flat_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFEAF4FF), const Color(0xFFF1F7FF).withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4E7FE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Perkembangan Mental",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: badgeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            diff >= 0 ? "+$diff Poin" : "$diff Poin",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: diff >= 0 ? colorEmerald : colorCoral, // 🔥 SINKRON: Sekarang otomatis pakai coral jika minus
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Perbandingan dari hasil skor tes pengujian sebelumnya",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, BuildContext context) {
    final score = item["final_score"] ?? 0;
    final level = item["level"] ?? "-";
    
    final rawDate = item["created_at"]?.toString() ?? "";
    final dateString = rawDate.contains(' ') ? rawDate.split(' ')[0] : (rawDate.length >= 10 ? rawDate.substring(0, 10) : "Baru saja");

    // 🔥 SINKRON: Pilihan warna item list mengacu pada hex static yang sama
    Color statusColor;
    if (score >= 80) {
      statusColor = colorEmerald;
    } else if (score >= 60) {
      statusColor = colorBlue;
    } else if (score >= 40) {
      statusColor = colorOrange;
    } else {
      statusColor = colorCoral; // Menggunakan coral untuk konsistensi level bawah
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed('/hasil', arguments: item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withOpacity(0.08),
                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "$score",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Assessment Kesehatan Mental",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 5),
                          Text(
                            dateString,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
