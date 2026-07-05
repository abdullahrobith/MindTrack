import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/beranda_controller.dart';
import '../../../data/models/article_model.dart';
import '../../../core/controllers/global_auth_controller.dart';

import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';

class BerandaView extends GetView<BerandaController> {
  const BerandaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<NavigationController>().currentIndex.value = 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: _buildAppBar(),

      body: RefreshIndicator(

        onRefresh: () async {

          controller.fetchArticles();

          controller.fetchWeeklyTrend();
        },

        child: SingleChildScrollView(

          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              _buildGreeting(),

              const SizedBox(height: 20),

              _buildSummaryCard(),

              const SizedBox(height: 25),
              
              _buildMentalProgressChart(),
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

      backgroundColor: const Color(0xFF2E66E7),

      elevation: 0,

      centerTitle: false,

      title: const Text(

        'MindTrack',

        style: TextStyle(

          color: Colors.white,

          fontWeight: FontWeight.bold,
        ),
      ),

      leading: const Icon(
        Icons.spa,
        color: Colors.white,
      ),

      actions: [],
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

  Widget _buildSummaryCard() {
    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [

            Color(0xFF2E66E7),

            Color(0xFF4B8DFF),
          ],
        ),

        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(

        children: [

          Row(

            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [

              const Text(

                'Ringkasan Hari Ini',

                style: TextStyle(

                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                  fontSize: 16,
                ),
              ),

              Container(

                padding: const EdgeInsets.symmetric(

                  horizontal: 10,

                  vertical: 5,
                ),

                decoration: BoxDecoration(

                  color: Colors.white.withOpacity(0.2),

                  borderRadius: BorderRadius.circular(10),
                ),

                child: const Text(

                  'Mental Health',

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 11,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          Row(

            children: [

              Expanded(

                child: _summaryBox(

                  Icons.auto_graph,

                  "Weekly Trend",

                  "Realtime",
                ),
              ),

              const SizedBox(width: 12),

              Expanded(

                child: _summaryBox(

                  Icons.article,

                  "Artikel",

                  "Alodokter",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Obx(() => LinearProgressIndicator(

                value: controller.weeklyProgress.value,

                backgroundColor: Colors.white24,

                color: Colors.white,

                minHeight: 8,
              )),
        ],
      ),
    );
  }

  Widget _summaryBox(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: Colors.white.withOpacity(0.15),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: Colors.white,
          ),

          const SizedBox(height: 12),

          Text(

            title,

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(

            value,

            style: const TextStyle(

              color: Colors.white,

              fontWeight: FontWeight.bold,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMentalProgressChart() {

  return Obx(() {

    if (controller.isLoadingMentalChart.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.mentalHistory.isEmpty) {
      return const SizedBox();
    }

    final histories = controller.mentalHistory;

    final latestScore =
        histories.first["final_score"] ?? 0;

    final oldestScore =
        histories.last["final_score"] ?? 0;

    final diff =
        latestScore - oldestScore;

    final chartColor =
        diff >= 0
            ? Colors.green
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.show_chart,
                color: Color(0xFF2E66E7),
              ),
              SizedBox(width: 8),
              Text(
                "Perkembangan Mental",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color: const Color(
                            0xFF2E66E7)
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                  child: Column(
                    children: [

                      const Text(
                        "Score Terakhir",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                          height: 5),

                      Text(
                        "$latestScore",
                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                          color: Color(
                              0xFF2E66E7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color: chartColor
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                  child: Column(
                    children: [

                      const Text(
                        "Perubahan",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                          height: 5),

                      Text(
                        diff >= 0
                            ? "+$diff"
                            : "$diff",
                        style:
                            TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              chartColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 250,
            child: LineChart(

              LineChartData(

                minY: 0,
                maxY: 100,

                borderData:
                    FlBorderData(
                  show: false,
                ),

                gridData:
                    FlGridData(
                  show: true,
                ),

                lineTouchData:
                    LineTouchData(

                  touchTooltipData:
                      LineTouchTooltipData(

                    getTooltipItems:
                        (spots) {

                      return spots
                          .map(
                            (spot) =>
                                LineTooltipItem(
                              "Score ${spot.y.toInt()}",
                              const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          )
                          .toList();
                    },
                  ),
                ),

                titlesData:
                    FlTitlesData(

                  topTitles:
                      const AxisTitles(),

                  rightTitles:
                      const AxisTitles(),

                  leftTitles:
                      AxisTitles(

                    sideTitles:
                        SideTitles(

                      showTitles: true,

                      interval: 20,

                      reservedSize: 35,

                      getTitlesWidget:
                          (value,
                              meta) {

                        return Text(
                          value
                              .toInt()
                              .toString(),
                          style:
                              const TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles:
                      AxisTitles(

                    sideTitles:
                        SideTitles(

                      showTitles: true,

                      interval: 1,

                      getTitlesWidget:
                          (value,
                              meta) {

                        final index =
                            value.toInt();

                        if (index <
                                0 ||
                            index >=
                                histories.length) {
                          return const SizedBox();
                        }

                        final date =
                            DateTime.parse(
                          histories[index]
                              ["created_at"],
                        );

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                                  top: 8),
                          child: Text(
                            "${date.day}/${date.month}",
                            style:
                                const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [

                  LineChartBarData(

                    isCurved: true,

                    color:
                        chartColor,

                    barWidth: 4,

                    dotData:
                        FlDotData(
                      show: true,
                    ),

                    belowBarData:
                        BarAreaData(
                      show: true,
                      color: chartColor
                          .withOpacity(
                              0.15),
                    ),

                    spots:
                        List.generate(

                      histories.length,

                      (index) {

                        final item =
                            histories[
                                index];

                        return FlSpot(
                          index
                              .toDouble(),
                          (item["final_score"] ??
                                  0)
                              .toDouble(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "${histories.length} assessment tercatat",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  });
}


Widget _trendTile(

  String title,

  int score,

  int change,

  Color color,
) {

  return Column(

    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(

            title,

            style: const TextStyle(

              fontWeight: FontWeight.bold,
            ),
          ),

          Column(

            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [

              Text(

                "$score",

                style: TextStyle(

                  color: color,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(

                change >= 0
                    ? "📈 +$change"
                    : "📉 $change",

                style: TextStyle(

                  fontSize: 11,

                  color: change >= 0
                      ? Colors.green
                      : Colors.red,
                ),
              )
            ],
          )
        ],
      ),

      const SizedBox(height: 8),

      ClipRRect(

        borderRadius:
            BorderRadius.circular(10),

        child: LinearProgressIndicator(

          value: score / 100,

          minHeight: 10,

          backgroundColor:
              Colors.grey.shade200,

          color: color,
        ),
      )
    ],
  );
}

  // =====================================================
  // WEEKLY TREND
  // =====================================================

  Widget _buildWeeklyTrend(BuildContext context) {

  return Obx(() {

    if (controller.isLoadingTrend.value) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          'Weekly Trend',

          style: TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 16,
          ),
        ),

        const SizedBox(height: 15),

        Container(

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(

            color: Get.find<GlobalAuthController>().isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            boxShadow: [

              BoxShadow(

                color:
                    Colors.black.withOpacity(0.04),

                blurRadius: 10,

                offset: const Offset(0, 5),
              )
            ],
          ),

          child: Column(

            children: [

              _trendTile(
                "Burnout",
                controller.burnoutTrend.value,
                controller.burnoutChange.value,
                Colors.orange,
              ),
              const SizedBox(height: 14),

              _trendTile(

                "Anxiety",

                controller.anxietyTrend.value,
                controller.anxietyChange.value,
                Colors.red,
              ),

              const SizedBox(height: 14),

              _trendTile(

                "Depression",

                controller.depressionTrend.value,
                controller.depressionChange.value,
                Colors.blue,
              ),
            ],
          ),
        )
      ],
    );
  });
}

  // =====================================================
  // HEADER ARTIKEL
  // =====================================================

  Widget _buildArticleHeader() {
  return const Text(
    "Artikel Kesehatan Mental",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}

  // =====================================================
  // SEARCH
  // =====================================================

  Widget _buildSearchBar(BuildContext context) {
  final TextEditingController
      searchController =
      TextEditingController();

  return Obx(() {
    final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Row(

    children: [

      Expanded(

        child: TextField(

          controller: searchController,

          onSubmitted: (value) {

            controller.searchArticle(value);
          },

          style: TextStyle(color: textColor),
          decoration: InputDecoration(

            hintText: "Cari artikel...",

            prefixIcon:
                const Icon(Icons.search),

            filled: true,

            fillColor: cardColor,

            contentPadding:
                const EdgeInsets.symmetric(
                    vertical: 14),

            border: OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(30),

              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      const SizedBox(width: 10),

      InkWell(

        onTap: () {

          controller.searchArticle(
            searchController.text,
          );
        },

        borderRadius:
            BorderRadius.circular(15),

        child: Container(

          padding:
              const EdgeInsets.all(14),

          decoration: BoxDecoration(

            color:
                const Color(0xFF2E66E7),

            borderRadius:
                BorderRadius.circular(15),
          ),

          child: const Icon(

            Icons.arrow_forward,

            color: Colors.white,
          ),
        ),
      )
    ],
  );
  });
}

  // =====================================================
  // ARTICLE SECTION
  // =====================================================

  Widget _buildArticleSection(BuildContext context) {
  return Obx(() {
    final data = controller.searchResult.isNotEmpty
        ? controller.searchResult
        : controller.articles;

    if (controller.isLoadingArticles.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text("Artikel tidak ditemukan"),
      );
    }

    final displayedArticles =
        controller.showAllArticles.value
            ? data
            : data.take(5).toList();

    return Column(
      children: [

        ...List.generate(
          displayedArticles.length,
          (index) {
            final article = displayedArticles[index];
            return _articleCard(context, article);
          },
        ),

        if (data.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InkWell(
              onTap: controller.toggleShowAllArticles,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      controller.showAllArticles.value
                          ? "Tampilkan Lebih Sedikit"
                          : "Lihat Semua",
                      style: const TextStyle(
                        color: Color(0xFF2E66E7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Icon(
                      controller.showAllArticles.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF2E66E7),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  });
}

  // =====================================================
  // ARTICLE CARD
  // =====================================================

  Widget _articleCard(
  BuildContext context,
  ArticleModel article,
) {
  final isDark = Get.find<GlobalAuthController>().isDarkMode.value;
  final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final descColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 5),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        // ==========================
        // IMAGE
        // ==========================

        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: Image.network(
            article.image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,

            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ==========================
              // CATEGORY
              // ==========================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  article.category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2E66E7),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================
              // TITLE
              // ==========================

              Text(
                article.title,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 10),

              // ==========================
              // DESCRIPTION
              // ==========================

              Text(
                article.description,
                maxLines: 4,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: descColor,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 16),

              // ==========================
              // BUTTON
              // ==========================

              Align(
                alignment:
                    Alignment.centerRight,
                child: InkWell(
                  onTap: () async {

                    final Uri uri =
                        Uri.parse(
                      article.url,
                    );

                    await launchUrl(
                      uri,
                      mode: LaunchMode
                          .externalApplication,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: const Color(
                          0xFF2E66E7),
                      borderRadius:
                          BorderRadius
                              .circular(14),
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [

                        Icon(
                          Icons.open_in_new,
                          color:
                              Colors.white,
                          size: 18,
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Baca Artikel",
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        )
                      ],
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
    final features = [
      {
        "title": "Musik Relaksasi",
        "icon": Icons.music_note,
        "route": "/relaxation-music",
      },
      {
        "title": "Jurnal Harian",
        "icon": Icons.edit_note,
        "route": "/journal",
      },
      {
        "title": "Pernapasan",
        "icon": Icons.air,
        "route": "/breathing",
      },
      {
        "title": "Afirmasi",
        "icon": Icons.favorite,
        "route": "/affirmation",
      },
    ];

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          "Relaksasi Cepat",

          style: TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 18,
          ),
        ),

        const SizedBox(height: 15),

        GridView.builder(

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

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

            return InkWell(
            borderRadius: BorderRadius.circular(20),

            onTap: () {
              Get.toNamed(
                item["route"] as String,
              );
            },

            child: Container(

              decoration: BoxDecoration(

                color: Get.theme.cardColor,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withOpacity(0.04),

                    blurRadius: 10,

                    offset: const Offset(0, 4),
                  )
                ],
              ),

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(

                    item['icon'] as IconData,

                    size: 34,

                    color: const Color(0xFF2E66E7),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    item['title'] as String,

                    style: const TextStyle(

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ),
            );
          },
        ),
      ],
    );
  }
}
