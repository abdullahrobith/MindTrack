import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/beranda_controller.dart';
import '../../../data/models/article_model.dart';
import '../../../core/controllers/global_auth_controller.dart';

import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';
const double _kChartCardHeight = 320;
class BerandaView extends GetView<BerandaController> {
  const BerandaView({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = Get.find<NavigationController>();

      if (nav.currentIndex.value != 0) {
        nav.currentIndex.value = 0;
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      
      appBar: _buildAppBar(),

      body: RefreshIndicator(

        onRefresh: () async {
          await Future.wait([
            controller.fetchArticles(),
            controller.fetchWeeklyTrend(),
            controller.fetchMentalHistory(),
            controller.fetchJournals(),
          ]);
        },

        child: SingleChildScrollView(

          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _buildGreeting(),

              const SizedBox(height: 20),

              _buildInsightSection(),
              const SizedBox(height: 25),

              _buildWeeklyTrend(context),

              const SizedBox(height: 30),

              _buildArticleHeader(),

              const SizedBox(height: 12),

              _buildSearchBar(context),

              const SizedBox(height: 20),

              _buildArticleSection(context),

              const SizedBox(height: 30),

              _buildQuickRelaxationGrid(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // =====================================================
  // APPBAR
  // =====================================================

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E66E7), Color(0xFF4A7DF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      // Judul diletakkan di kiri dengan ukuran yang lebih tegas
      title: const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          'MindTrack',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      // Ikon Spa diletakkan di kiri sebagai penanda branding yang simpel
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Icon(Icons.spa_rounded, color: Colors.white, size: 28),
      ),
      // Aksi dihapus (kosong) agar area kanan bersih
      actions: const [],
    );
  }

  // =====================================================
  // GREETING
  // =====================================================

  Widget _buildGreeting() {
    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Obx(() => Text(

              'Selamat datang, ${controller.userName}',

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),

        const SizedBox(height: 8),

        const Text(

          'Pantau kesehatan mentalmu dan temukan insight terbaru dari data global.',

          style: TextStyle(

            color: Colors.grey,

            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SUMMARY
  // =====================================================

// ============================================================
// TAMBAHKAN INI DI CONTROLLER (GetX) KAMU:
//
//   final PageController chartPageController = PageController();
//   final RxInt currentChartPage = 0.obs;
//
// (selectedChartIndex, selectedPieIndex, chartFilterIndex,
//  isLoadingMentalChart, isLoadingMoodChart, mentalHistory,
//  journals — semua tetap sama seperti punya kamu sekarang)
// ============================================================
/// Widget utama: gabungan kedua chart dalam satu PageView yang bisa digeser
Widget _buildInsightSection() {
  return Column(
    children: [
      SizedBox(
        height: _kChartCardHeight,
        child: PageView(
          controller: controller.chartPageController,
          onPageChanged: (index) {
            controller.currentChartPage.value = index;
            // reset seleksi titik/segmen saat pindah halaman biar tidak nyangkut
            controller.selectedChartIndex.value = -1;
            controller.selectedPieIndex.value = -1;
          },
          children: [
            _buildSummaryCard(),
            _buildMoodChart(),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _buildPageIndicator(),
    ],
  );
}

/// Indikator titik (dot) di bawah card, dengan animasi saat halaman aktif berubah
Widget _buildPageIndicator() {
  return Obx(() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = controller.currentChartPage.value == index;
        return GestureDetector(
          onTap: () {
            controller.chartPageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1E4AD9) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  });
}

// ============================================================
// CARD 1: Tren Mental (Line Chart)
// ============================================================
Widget _buildSummaryCard() {
  return Obx(() {
    // 1. State Loading
    if (controller.isLoadingMentalChart.value) {
      return Container(
        height: _kChartCardHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E66E7), Color(0xFF4B8DFF)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // 2. State Data Kosong
    if (controller.mentalHistory.isEmpty) {
      return Container(
        height: _kChartCardHeight,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart_rounded, size: 55, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "Belum ada riwayat assessment",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Pemrosesan Data & Fitur Filter Dasbor
    var histories = List<Map<String, dynamic>>.from(controller.mentalHistory);
    histories.sort(
      (a, b) => DateTime.parse(a["created_at"]).compareTo(DateTime.parse(b["created_at"])),
    );

    if (controller.chartFilterIndex.value == 1 && histories.length > 7) {
      histories = histories.sublist(histories.length - 7);
    }

    final int activeIndex = controller.selectedChartIndex.value != -1 &&
            controller.selectedChartIndex.value < histories.length
        ? controller.selectedChartIndex.value
        : histories.length - 1;

    final activeItem = histories[activeIndex];
    final activeScore = (activeItem["final_score"] ?? 0).toDouble();
    final activeDate = DateTime.parse(activeItem["created_at"]);

    final latestScore = (histories.last["final_score"] ?? 0).toDouble();
    double previousScore = latestScore;
    if (histories.length >= 2) {
      previousScore = (histories[histories.length - 2]["final_score"] ?? 0).toDouble();
    }
    final diff = latestScore - previousScore;

    String statusLabel = "Stabil";
    String diffText = "";
    Color statusColor = Colors.white;
    IconData statusIcon = Icons.trending_flat_rounded;

    if (diff > 0) {
      statusLabel = "Meningkat";
      diffText = "+${diff.toStringAsFixed(0)}";
      statusColor = Colors.greenAccent;
      statusIcon = Icons.trending_up_rounded;
    } else if (diff < 0) {
      statusLabel = "Menurun";
      diffText = diff.toStringAsFixed(0);
      statusColor = const Color(0xFFFF8A8A);
      statusIcon = Icons.trending_down_rounded;
    }

    double xInterval = 1;
    if (histories.length > 5) {
      xInterval = (histories.length / 5).ceilToDouble();
    }

    // 4. Main UI Card
    return Container(
      height: _kChartCardHeight,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E4AD9), Color(0xFF4B8DFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E66E7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Judul + Filter Tab
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Tren Mental',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildFilterChip("Semua", 0),
                  const SizedBox(width: 6),
                  _buildFilterChip("7 Terakhir", 1),
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$statusLabel Berdasarkan Data Terakhir",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                if (diff != 0) ...[
                  const SizedBox(width: 4),
                  Text(diffText, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Area Grafik Garis
          Expanded(
            child: LineChart(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              LineChartData(
                minX: -0.2,
                maxX: (histories.length - 1).toDouble() + 0.2,
                minY: 0,
                maxY: 110,
                clipData: const FlClipData.none(),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    if (!event.isInterestedForInteractions ||
                        touchResponse == null ||
                        touchResponse.lineBarSpots == null) {
                      controller.selectedChartIndex.value = -1;
                      return;
                    }
                    final touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
                    if (touchedIndex >= 0 && touchedIndex < histories.length) {
                      controller.selectedChartIndex.value = touchedIndex;
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => Colors.white,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final date = DateTime.parse(histories[spot.x.toInt()]["created_at"]);
                        return LineTooltipItem(
                          "${date.day}/${date.month}\nSkor: ${spot.y.toInt()}",
                          const TextStyle(color: Color(0xFF1E4AD9), fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.white.withOpacity(0.15), strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1)),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value > 100) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: xInterval,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= histories.length) return const SizedBox();
                        if (value != value.toInt()) return const SizedBox();

                        final date = DateTime.parse(histories[index]["created_at"]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "${date.day}/${date.month}",
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: .3,
                    color: Colors.white,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    preventCurveOverShooting: true,
                    spots: List.generate(histories.length, (index) {
                      return FlSpot(index.toDouble(), (histories[index]["final_score"] ?? 0).toDouble());
                    }),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isSelected = index == activeIndex && controller.selectedChartIndex.value != -1;
                        return FlDotCirclePainter(
                          radius: isSelected ? 6 : 3.5,
                          color: isSelected ? Colors.amber : const Color(0xFF1E4AD9),
                          strokeWidth: isSelected ? 3 : 2.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.00)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // BOTTOM PANEL: info dinamis berdasarkan titik yang disentuh
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: controller.selectedChartIndex.value != -1
                  ? Colors.white.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedChartIndex.value != -1 ? "Skor Data Terpilih" : "Skor Asesmen Terakhir",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${activeScore.toStringAsFixed(0)} Poin",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Waktu Asesmen",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${activeDate.day}/${activeDate.month}/${activeDate.year}",
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

// Helper tombol filter di dalam card tren mental
Widget _buildFilterChip(String label, int index) {
  final isSelected = controller.chartFilterIndex.value == index;
  return GestureDetector(
    onTap: () {
      controller.chartFilterIndex.value = index;
      controller.selectedChartIndex.value = -1;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF1E4AD9) : Colors.white.withOpacity(0.8),
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

// ============================================================
// CARD 2: Distribusi Emosi (Pie Chart)
// ============================================================
Widget _buildMoodChart() {
  return Obx(() {
    // ==========================================
    // 1. STATE: LOADING
    // ==========================================
    if (controller.isLoadingMoodChart.value) {
      return Container(
        height: _kChartCardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E66E7), Color(0xFF4B8DFF)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // ==========================================
    // 2. STATE: KOSONG (EMPTY STATE)
    // ==========================================
    if (controller.journals.isEmpty) {
      return Container(
        height: _kChartCardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2E66E7).withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E66E7).withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ornamen Background Tipis (Buku Harian)
            Positioned(
              right: -20,
              top: -20,
              child: Icon(Icons.menu_book_rounded, size: 120, color: Colors.grey.withOpacity(0.04)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E66E7).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note_rounded, size: 42, color: Color(0xFF2E66E7)),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Belum Ada Data Jurnal",
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "Grafik mood akan muncul di sini setelah kamu mulai menulis jurnal harian.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                
                // TOMBOL MENUJU HALAMAN JURNAL (Empty State)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Ubah navigasi ini sesuai nama halaman Jurnal Anda
                    Get.toNamed('/journal');
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Tulis Jurnal Sekarang"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E66E7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }

    // ==========================================
    // 3. STATE: ADA DATA (PREMIUM UI TANPA BLUR)
    // ==========================================
    final Map<String, int> moodCount = {
      "😊": 0,
      "😌": 0,
      "😔": 0,
      "😢": 0,
      "😡": 0,
    };

    for (final item in controller.journals) {
      final mood = item["mood"];
      if (moodCount.containsKey(mood)) {
        moodCount[mood] = moodCount[mood]! + 1;
      }
    }

    final total = moodCount.values.fold(0, (a, b) => a + b);

    // Palet Warna UI Modern
    final moodConfigs = [
      {"emoji": "😊", "name": "Bahagia", "color": const Color(0xFF34D399)},
      {"emoji": "😌", "name": "Tenang",  "color": const Color(0xFF60A5FA)},
      {"emoji": "😔", "name": "Sedih",   "color": const Color(0xFFFBBF24)},
      {"emoji": "😢", "name": "Kecewa",  "color": const Color(0xFFA78BFA)},
      {"emoji": "😡", "name": "Marah",   "color": const Color(0xFFFB7185)},
    ];

    final selectedIdx = controller.selectedPieIndex.value;
    String centerText = "";
    String centerSubText = "";
    
    if (selectedIdx >= 0 && selectedIdx < moodConfigs.length) {
      final value = moodCount[moodConfigs[selectedIdx]["emoji"]]!;
      final percent = total == 0 ? 0 : (value / total * 100);
      centerText = "${percent.toStringAsFixed(0)}%";
      centerSubText = moodConfigs[selectedIdx]["name"] as String;
    } else {
      centerText = "$total";
      centerSubText = "Catatan"; 
    }

    return Container(
      constraints: BoxConstraints(minHeight: _kChartCardHeight),
      decoration: BoxDecoration(
        // Gradien Premium (Tanpa Blur)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF163CB3), Color(0xFF3B7CFF)], 
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E66E7).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER DENGAN TOMBOL NAVIGASI ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Ubah ke center agar tombol sejajar
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mood Harian",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Berdasarkan $total catatan terakhirmu",
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // TOMBOL MENUJU HALAMAN JURNAL (Data State)
                Material(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Ubah navigasi ini sesuai nama halaman Jurnal Anda
                      // Contoh: Get.to(() => JournalPage()); 
                      Get.toNamed('/journal');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Tulis Jurnal",
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- CHART & LEGEND ---
            Expanded(
              child: Row(
                children: [
                  // === KIRI: PIE CHART ===
                  Expanded(
                    flex: 11,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Teks Dinamis di Tengah
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                          },
                          child: Column(
                            key: ValueKey<String>(centerText),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                centerText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                centerSubText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Chart
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                if (event is FlTapUpEvent) {
                                  HapticFeedback.lightImpact();
                                  if (response == null || response.touchedSection == null) {
                                    controller.selectedPieIndex.value = -1;
                                    return;
                                  }
                                  final tappedIndex = response.touchedSection!.touchedSectionIndex;
                                  controller.selectedPieIndex.value = controller.selectedPieIndex.value == tappedIndex ? -1 : tappedIndex;
                                }
                              },
                            ),
                            centerSpaceRadius: 40, 
                            sectionsSpace: 4, 
                            sections: List.generate(5, (i) {
                              final config = moodConfigs[i];
                              final emoji = config["emoji"] as String;
                              final value = moodCount[emoji]!.toDouble();
                              final selected = controller.selectedPieIndex.value == i;

                              return PieChartSectionData(
                                color: config["color"] as Color,
                                value: value,
                                radius: selected ? 58 : 46,
                                title: "", 
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(selected ? 0.9 : 0.0), 
                                  width: selected ? 4 : 0,
                                ),
                                badgeWidget: value > 0 
                                  ? AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutBack,
                                      padding: const EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
                                        ],
                                      ),
                                      child: Text(emoji, style: TextStyle(fontSize: selected ? 18 : 14)),
                                    ) 
                                  : const SizedBox.shrink(),
                                badgePositionPercentageOffset: selected ? 1.05 : 0.95, 
                              );
                            }),
                          ),
                          swapAnimationDuration: const Duration(milliseconds: 500),
                          swapAnimationCurve: Curves.easeOutBack,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // === KANAN: LEGEND ===
                  Expanded(
                    flex: 10,
                    child: SingleChildScrollView( 
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(5, (i) {
                          final config = moodConfigs[i];
                          final name = config["name"] as String;
                          final color = config["color"] as Color;
                          final value = moodCount[config["emoji"]]!;
                          final percent = total == 0 ? 0 : (value / total * 100);
                          
                          final selected = controller.selectedPieIndex.value == i;
                          
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.selectedPieIndex.value = selected ? -1 : i;
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        boxShadow: selected ? [
                                          BoxShadow(color: color, blurRadius: 6, spreadRadius: 1)
                                        ] : [],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                            ),
                                          ),
                                          if (selected && value > 0) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              "${percent.toStringAsFixed(1)}% dari total",
                                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9),
                                            )
                                          ]
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "$value",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: selected ? FontWeight.w900 : FontWeight.bold,
                                        fontSize: selected ? 15 : 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}
// Widget _trendTile(

//   String title,

//   int score,

//   int change,

//   Color color,
// ) {

//   return Column(

//     crossAxisAlignment:
//         CrossAxisAlignment.start,

//     children: [

//       Row(

//         mainAxisAlignment:
//             MainAxisAlignment.spaceBetween,

//         children: [

//           Text(

//             title,

//             style: const TextStyle(

//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           Column(

//             crossAxisAlignment:
//                 CrossAxisAlignment.end,

//             children: [

//               Text(

//                 "$score",

//                 style: TextStyle(

//                   color: color,

//                   fontWeight:
//                       FontWeight.bold,
//                 ),
//               ),

//               Text(

//                 change >= 0
//                     ? "📈 +$change"
//                     : "📉 $change",

//                 style: TextStyle(

//                   fontSize: 11,

//                   color: change >= 0
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//               )
//             ],
//           )
//         ],
//       ),

//       const SizedBox(height: 8),

//       ClipRRect(

//         borderRadius:
//             BorderRadius.circular(10),

//         child: LinearProgressIndicator(

//           value: score / 100,

//           minHeight: 10,

//           backgroundColor:
//               Colors.grey.shade200,

//           color: color,
//         ),
//       )
//     ],
//   );
// }

  // =====================================================
  // WEEKLY TREND
  // =====================================================

 Widget _buildWeeklyTrend(BuildContext context) {
  // Variabel internal untuk mengatur state tile yang sedang terbuka/aktif
  final RxString expandedTrend = ''.obs;
  final RxString showChartFor = ''.obs; 

  return Obx(() {
    // 1. KONDISI LOADING: Tetap terjaga di paling atas
    if (controller.isLoadingTrend.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0), // Sedikit dinaikkan agar lebih lega saat loading
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    const primaryBlue = Color(0xFF2E66E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // --- HEADER SEKSYEN: SEKARANG SUDAH SERAGAM KELAS PREMIUM ---
        // Ganti bagian Row header di dalam _buildWeeklyTrend() dengan ini:
        Row(
          children: [
            // Garis aksen vertikal minimalis
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tren Pencarian Mingguan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.2,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Topik yang paling banyak dicari oleh pengguna minggu ini",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // --- WADAH KARTU UTAMA TREN ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              // Item 1: Burnout
              _buildInteractiveTrendTile(
                title: "Burnout",
                currentTrend: controller.burnoutTrend.value,
                change: controller.burnoutChange.value,
                color: Colors.orange,
                expandedTrend: expandedTrend,
                showChartFor: showChartFor, 
                isDark: isDark,
              ),
              Divider(
                height: 16, 
                thickness: 1, 
                color: isDark ? Colors.white10 : Colors.grey.shade100,
              ),
              
              // Item 2: Anxiety
              _buildInteractiveTrendTile(
                title: "Anxiety",
                currentTrend: controller.anxietyTrend.value,
                change: controller.anxietyChange.value,
                color: Colors.redAccent,
                expandedTrend: expandedTrend,
                showChartFor: showChartFor, 
                isDark: isDark,
              ),
              Divider(
                height: 16, 
                thickness: 1, 
                color: isDark ? Colors.white10 : Colors.grey.shade100,
              ),
              
              // Item 3: Depression
              _buildInteractiveTrendTile(
                title: "Depression",
                currentTrend: controller.depressionTrend.value,
                change: controller.depressionChange.value,
                color: Colors.blueAccent,
                expandedTrend: expandedTrend,
                showChartFor: showChartFor, 
                isDark: isDark,
              ),
            ],
          ),
        )
      ],
    );
  });
}
Widget _buildInteractiveTrendTile({
  required String title,
  required dynamic currentTrend,
  required dynamic change,
  required Color color,
  required RxString expandedTrend,
  required RxString showChartFor, // <--- Diterima di sini
  required bool isDark,
}) {
  final double trendValue = double.tryParse(currentTrend.toString()) ?? 0.0;
  final double changeValue = double.tryParse(change.toString()) ?? 0.0;
  
  final bool isUp = changeValue > 0;
  final bool isNeutral = changeValue == 0;
  
  String insightText = "";
  if (isUp) {
    insightText = "Volume pencarian $title minggu ini meningkat tajam di internet. Waspadai tren kelelahan mental di sekitarmu.";
  } else if (changeValue < 0) {
    insightText = "Volume pencarian $title menurun. Tren menunjukkan perbaikan kondisi secara umum minggu ini.";
  } else {
    insightText = "Tren pencarian stabil, tidak ada lonjakan signifikan minggu ini.";
  }

  return Obx(() {
    final isExpanded = expandedTrend.value == title;
    final isChartVisible = showChartFor.value == title; // Status apakah grafik terbuka inline

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isExpanded) {
            expandedTrend.value = '';
            showChartFor.value = ''; // Ikut tutup grafiknya jika tile ditutup
          } else {
            expandedTrend.value = title;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isExpanded 
                ? (isDark ? Colors.white.withOpacity(0.05) : color.withOpacity(0.05)) 
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER KARTU ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isNeutral
                          ? Colors.grey.withOpacity(0.2)
                          : isUp
                              ? Colors.red.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isNeutral ? Icons.trending_flat : (isUp ? Icons.trending_up : Icons.trending_down),
                          size: 14,
                          color: isNeutral ? Colors.grey : (isUp ? Colors.red : Colors.green),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${changeValue > 0 ? '+' : ''}${changeValue.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isNeutral ? Colors.grey : (isUp ? Colors.red : Colors.green),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 12),
              
              // --- VISUAL BAR (0 - 100) ---
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: trendValue / 100,
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${trendValue.toInt()}/100",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),

              // --- AREA INSIGHT & GRAFIK INLINE (Expandable) ---
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4, right: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insightText,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 14),
                            
                            // TOMBOL TOGGLE TAMPILKAN GRAFIK
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (isChartVisible) {
                                    showChartFor.value = '';
                                  } else {
                                    showChartFor.value = title;
                                    controller.trendRangeFilter.value = 7; // Reset filter ke 7 hari setiap dibuka
                                  }
                                },
                                icon: Icon(isChartVisible ? Icons.keyboard_arrow_up_rounded : Icons.show_chart_rounded, size: 16),
                                label: Text(
                                  isChartVisible ? "Sembunyikan Grafik" : "Lihat Detail Grafik",
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),

                            // --- GRAFIK & FILTER DI BAWAH TOMBOL ---
                            if (isChartVisible) ...[
                              const SizedBox(height: 16),
                              // Filter Hari Mini
                              // --- GANTI AREA WRAP CHOICECHIP LAMA DENGAN KODE SLEEK INI ---
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4), // Jarak dalam wadah kapsul
                                  decoration: BoxDecoration(
                                    // Latar belakang menyatu untuk semua tombol
                                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // Agar lebar wadah pas dengan konten
                                    children: [7, 30, 90].map((days) {
                                      final isSelected = controller.trendRangeFilter.value == days;
                                      
                                      return GestureDetector(
                                        onTap: () => controller.trendRangeFilter.value = days,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 220),
                                          curve: Curves.easeInOut,
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                          decoration: BoxDecoration(
                                            // Tombol aktif mengambil warna kategori, tombol tidak aktif transparan
                                            color: isSelected ? color : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                            
                                            // Efek bayangan bersinar halus (glow effect) hanya untuk yang aktif
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: color.withOpacity(0.35),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: Text(
                                            "$days Hari",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              // Warna teks kontras otomatis berubah secara realtime
                                              color: isSelected
                                                  ? Colors.white
                                                  : (isDark ? Colors.white60 : Colors.black54),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
// -------------------------------------------------------------,
                              const SizedBox(height: 16),
                              
                              // Kotak Wadah Grafik LineChart (Beri tinggi solid)
                              // --- GANTI KOTAK WADAH GRAFIK LAMA DENGAN INI ---
                              SizedBox(
                                height: 180, // Sedikit dinaikkan agar angka sumbu bawah tidak terpotong
                                child: () {
                                  final chartPoints = controller.getTrendData(title, controller.trendRangeFilter.value);
                                  
                                  if (chartPoints.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "Data historis kosong di database",
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    );
                                  }

                                  return LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 100,
                                      
                                      // 1. FITUR INTERAKTIF: Memunculkan Angka Saat Titik Grafik Disentuh (Tooltip)
                                      lineTouchData: LineTouchData(
                                        handleBuiltInTouches: true,
                                        // Ganti bagian ini:
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipColor: (touchedSpot) => color.withOpacity(0.9),
                                            // HAPUS BARIS INI: tooltipRoundedRadius: 8,
                                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                            return touchedBarSpots.map((barSpot) {
                                              return LineTooltipItem(
                                                "Skor: ${barSpot.y.toInt()}",
                                                const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList();
                                          },
                                        ),
                                        // Efek lingkaran membesar saat indikator disentuh
                                        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                          return spotIndexes.map((spotIndex) {
                                            return TouchedSpotIndicatorData(
                                              FlLine(color: color.withOpacity(0.3), strokeWidth: 3),
                                              FlDotData(
                                                getDotPainter: (spot, percent, barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 6,
                                                    color: color,
                                                    strokeWidth: 2,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),

                                      // 2. TAMPILKAN ANGKA DI SUMBU (Kiri & Bawah)
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        
                                        // Sumbu Kiri (Nilai 0 - 100)
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            interval: 25, // Memunculkan angka kelipatan 25 (0, 25, 50, 75, 100)
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: Text(
                                                  value.toInt().toString(),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white54 : Colors.black45,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        
                                        // Sumbu Bawah (Garis Kronologis/Waktu)
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 22,
                                            // Menghitung interval agar teks bawah tidak menumpuk berantakan
                                            interval: (chartPoints.length / 4).clamp(1, 90).toDouble(), 
                                            getTitlesWidget: (value, meta) {
                                              // Menampilkan penanda posisi data (misal: Titik ke-1, Titik ke-5, dst)
                                              if (value == 0) return const Text('');
                                              return Text(
                                                "H-${chartPoints.length - value.toInt()}",
                                                style: TextStyle(
                                                  color: isDark ? Colors.white38 : Colors.black38,
                                                  fontSize: 9,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      // 3. DESAIN GARIS LATAR (Grid) Yang Lebih Lembut
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false, // Hanya garis horizontal agar bersih
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                            strokeWidth: 1,
                                            dashArray: [4, 4], // Membuat garis putus-putus bergaya modern
                                          );
                                        },
                                      ),

                                      // 4. MATIKAN BORDER KOTAK YANG KAKU
                                      borderData: FlBorderData(show: false),

                                      // 5. KUSTOMISASI GARIS UTAMA GRAFIK (Gradient & Glow)
                                      // Ganti bagian ini:
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: chartPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                          isCurved: true,
                                          curveSmoothness: 0.25, // <--- UBAH DARI curveRadius MENJADI curveSmoothness
                                          color: color,
                                          barWidth: 3.5,
                                          isStrokeCapRound: true,
                                          
                                          // Efek Titik kecil di setiap koordinat asli
                                          dotData: FlDotData(
                                            show: chartPoints.length <= 7, // Hanya munculkan titik permanen jika datanya sedikit (7 hari) agar tidak sesak
                                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                              radius: 3,
                                              color: Colors.white,
                                              strokeWidth: 2,
                                              strokeColor: color,
                                            ),
                                          ),
                                          
                                          // Gradien warna transparan di bawah garis grafik (Efek Area Chart)
                                          belowBarData: BarAreaData(
                                            show: true,
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                color.withOpacity(0.25),
                                                color.withOpacity(0.00),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }(),
                              ),
                            ]
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

// =====================================================
// 1. ARTICLE HEADER
// =====================================================

Widget _buildArticleHeader() {
  return Obx(() {
    final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
    const primaryBlue = Color(0xFF2E66E7);

    return Row(
      children: [
        // Garis aksen vertikal minimalis pengganti ikon
        Container(
          width: 4,
          height: 24, // Menyesuaikan tinggi tumpukan teks
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        
        // Teks Judul & Sub-judul
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Artikel Kesehatan Mental",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.2,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Wawasan & tips terbaru dari Alodokter",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });
}

// =====================================================
// 2. SEARCH BAR
// =====================================================

Widget _buildSearchBar(BuildContext context) {
  final TextEditingController searchController = TextEditingController();

  return Obx(() {
    final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    const primaryBlue = Color(0xFF2E66E7);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onSubmitted: (value) => controller.searchArticle(value),
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Cari topik artikel...",
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black45),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => controller.searchArticle(searchController.text),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  });
}

// =====================================================
// 3. ARTICLE SECTION
// =====================================================

Widget _buildArticleSection(BuildContext context) {
  return Obx(() {
    final data = controller.searchResult.isNotEmpty 
        ? controller.searchResult 
        : controller.articles;

    if (controller.isLoadingArticles.value) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.article_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                "Artikel tidak ditemukan",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final displayedArticles = controller.showAllArticles.value ? data : data.take(5).toList();
    const primaryBlue = Color(0xFF2E66E7);

    return Column(
      children: [
        ...List.generate(
          displayedArticles.length,
          (index) => _articleCard(context, displayedArticles[index]),
        ),
        
        // Tombol Toggle Tampilkan Lebih Banyak / Sedikit
        if (data.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: TextButton.icon(
              onPressed: controller.toggleShowAllArticles,
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: primaryBlue.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: Text(
                controller.showAllArticles.value ? "Tampilkan Lebih Sedikit" : "Lihat Semua (${data.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              label: Icon(
                controller.showAllArticles.value ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ),
      ],
    );
  });
}

// =====================================================
// 4. ARTICLE CARD
// =====================================================

Widget _articleCard(BuildContext context, ArticleModel article) {
  final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
  final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final descColor = isDark ? Colors.white60 : Colors.black54;
  const primaryBlue = Color(0xFF2E66E7);

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
          blurRadius: 15,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gambar Artikel
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Image.network(
            article.image,
            height: 170, // Sedikit dipertajam proporsinya
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 170,
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                child: Center(
                  child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey.shade400),
                ),
              );
            },
          ),
        ),

        // Konten Artikel
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Kategori
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: primaryBlue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Judul
              Text(
                article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.3,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(
                article.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: descColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Baca
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri uri = Uri.parse(article.url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text(
                    "Baca Artikel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}

  // =====================================================
  // RELAKSASI
  // =====================================================

Widget _buildQuickRelaxationGrid() {
  // 1. Definisikan konfigurasi fitur dengan warna ikon & background badge masing-masing
  final features = [
    {
      "title": "Musik Relaksasi",
      "icon": Icons.music_note_rounded,
      "route": "/relaxation-music",
      "color": Colors.indigo,
      "bgColor": Colors.indigo.withOpacity(0.12),
    },
    {
      "title": "Jurnal Harian",
      "icon": Icons.edit_note_rounded,
      "route": "/journal",
      "color": Colors.orange.shade700,
      "bgColor": Colors.orange.withOpacity(0.12),
    },
    {
      "title": "Latihan Napas",
      "icon": Icons.air_rounded,
      "route": "/breathing",
      "color": Colors.teal,
      "bgColor": Colors.teal.withOpacity(0.12),
    },
    {
      "title": "Kata Afirmasi",
      "icon": Icons.favorite_rounded,
      "route": "/affirmation",
      "color": Colors.pink,
      "bgColor": Colors.pink.withOpacity(0.12),
    },
  ];

  return Obx(() {
    final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    const primaryBlue = Color(0xFF2E66E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER SEKSYEN ---
        // Ganti bagian Row header di dalam _buildQuickRelaxationGrid() dengan ini:
        Row(
          children: [
            // Garis aksen vertikal minimalis
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Relaksasi Cepat",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.2,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Ambil jeda sejenak untuk menenangkan pikiranmu",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- GRID MENU RELAKSASI ---
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15, // Proporsi kartu sedikit lebih ramping & pas
          ),
          itemBuilder: (context, index) {
            final item = features[index];
            final itemColor = item["color"] as Color;
            final badgeBg = item["bgColor"] as Color;

            return Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(24), // Sudut melengkung premium
              clipBehavior: Clip.antiAlias, // Memastikan ripple effect terpotong rapi di ujung
              child: InkWell(
                onTap: () => Get.toNamed(item["route"] as String),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Mengubah ke rata kiri agar lebih modern
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memisahkan ikon di atas & teks di bawah
                    children: [
                      // Lingkaran wadah ikon (Badge)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 26,
                          color: itemColor,
                        ),
                      ),
                      
                      // Teks Judul Menu & Panah Indikator Kecil
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: isDark ? Colors.white30 : Colors.black26,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  });
}
}

