import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/network_config.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../data/models/article_model.dart';
import '../../../data/providers/assessment_provider.dart';

class BerandaController extends GetxController {
  // =====================================================
  // USER
  // =====================================================

  final auth = Get.find<GlobalAuthController>();

  String get userName =>
      auth.currentUser.value?.name ?? "User";

  RxDouble weeklyProgress = 0.8.obs;

  // =====================================================
  // ARTICLE
  // =====================================================

  var articles = <ArticleModel>[].obs;
  var searchResult = <ArticleModel>[].obs;
  var isLoadingArticles = false.obs;

  final showAllArticles = false.obs;

  // =====================================================
  // WEEKLY TREND
  // =====================================================

  var burnoutTrend = 0.obs;
  var anxietyTrend = 0.obs;
  var depressionTrend = 0.obs;

  var burnoutChange = 0.obs;
  var anxietyChange = 0.obs;
  var depressionChange = 0.obs;

  var isLoadingTrend = false.obs;

  // =====================================================
  // MENTAL HISTORY CHART
  // =====================================================

  final AssessmentProvider assessmentProvider =
      AssessmentProvider();

  final mentalHistory =
      <Map<String, dynamic>>[].obs;

  final isLoadingMentalChart = false.obs;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    fetchArticles();
    fetchWeeklyTrend();
    fetchMentalHistory();
  }

  // =====================================================
  // ARTICLE
  // =====================================================

  Future<void> fetchArticles() async {
    try {
      isLoadingArticles.value = true;

      final response = await http.get(
        Uri.parse(
          '${NetworkConfig.baseUrl}/articles',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List data =
            jsonDecode(response.body);

        articles.value = data
            .map(
              (e) => ArticleModel.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      print("ERROR ARTICLE: $e");
    } finally {
      isLoadingArticles.value = false;
    }
  }

  Future<void> searchArticle(
    String keyword,
  ) async {
    try {
      isLoadingArticles.value = true;

      final response = await http.get(
        Uri.parse(
          '${NetworkConfig.baseUrl}/search-realtime/$keyword',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List data =
            jsonDecode(response.body);

        searchResult.value = data
            .map(
              (e) => ArticleModel.fromJson(e),
            )
            .toList();
      }
    } catch (e) {
      print(e);
    } finally {
      isLoadingArticles.value = false;
    }
  }

  void toggleShowAllArticles() {
    showAllArticles.value =
        !showAllArticles.value;
  }

  // =====================================================
  // WEEKLY TREND
  // =====================================================

  Future<void> fetchWeeklyTrend() async {
    try {
      isLoadingTrend.value = true;

      final response = await http.get(
        Uri.parse(
          '${NetworkConfig.baseUrl}/weekly-trend',
        ),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        burnoutTrend.value =
            data['burnout']['score'];

        burnoutChange.value =
            data['burnout']['change'];

        anxietyTrend.value =
            data['anxiety']['score'];

        anxietyChange.value =
            data['anxiety']['change'];

        depressionTrend.value =
            data['depression']['score'];

        depressionChange.value =
            data['depression']['change'];
      }
    } catch (e) {
      print(e);
    } finally {
      isLoadingTrend.value = false;
    }
  }

  // =====================================================
  // MENTAL HISTORY
  // =====================================================

  Future<void> fetchMentalHistory() async {
    try {
      isLoadingMentalChart.value = true;

      final result =
          await assessmentProvider
              .getHistory();

      mentalHistory.value =
          List<Map<String, dynamic>>.from(
        result,
      );

      // urutkan dari yang paling lama ke terbaru
      mentalHistory.sort(
        (a, b) => a["created_at"]
            .toString()
            .compareTo(
              b["created_at"].toString(),
            ),
      );
    } catch (e) {
      print(
        "ERROR MENTAL HISTORY: $e",
      );
    } finally {
      isLoadingMentalChart.value = false;
    }
  }
}