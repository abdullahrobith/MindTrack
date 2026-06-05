import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/beranda_controller.dart';
import '../../../data/models/article_model.dart';
import '../../../core/controllers/global_auth_controller.dart';

import '../../../widgets/main_bottom_nav.dart';

class BerandaView extends GetView<BerandaController> {
  const BerandaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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

      actions: [

        Padding(

          padding: const EdgeInsets.only(right: 15),

          child: InkWell(

            borderRadius: BorderRadius.circular(50),

            onTap: () => Get.toNamed('/profil'),

            child: const CircleAvatar(

              backgroundColor: Colors.white,

              child: Icon(

                Icons.person,

                color: Color(0xFF2E66E7),
              ),
            ),
          ),
        )
      ],
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
    return Row(

      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        const Text(

          "Artikel Kesehatan Mental",

          style: TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 18,
          ),
        ),

        TextButton(

          onPressed: () {},

          child: const Text("Lihat Semua"),
        )
      ],
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

      return Column(

        children: List.generate(

          data.length,

          (index) {

            final article = data[index];

            return _articleCard(context, article);
          },
        ),
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
        "title": "Meditasi",
        "icon": Icons.self_improvement
      },

      {
        "title": "Musik",
        "icon": Icons.music_note
      },

      {
        "title": "Jurnal",
        "icon": Icons.edit_note
      },

      {
        "title": "Pernapasan",
        "icon": Icons.air
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

            return Container(

              decoration: BoxDecoration(

                color: Colors.white,

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
            );
          },
        ),
      ],
    );
  }
}