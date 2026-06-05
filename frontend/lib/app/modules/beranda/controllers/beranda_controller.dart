import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;  

import 'package:capstone/app/data/models/article_model.dart';
import '../../../core/controllers/global_auth_controller.dart';
import '../../../core/config/network_config.dart';

class BerandaController extends GetxController {

  // =====================================================
  // USER
  // =====================================================

  final auth = Get.find<GlobalAuthController>();
  String get userName => auth.currentUser.value?.name ?? "User";

  RxDouble weeklyProgress = 0.8.obs;

  // =====================================================
  // ARTICLE
  // =====================================================
  var articles = <ArticleModel>[].obs;

  var searchResult = <ArticleModel>[].obs;

  var isLoadingArticles = false.obs;

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
  // INIT
  // =====================================================

  @override
  void onInit() {

    fetchArticles();

    fetchWeeklyTrend();

    super.onInit();
  }

  // =====================================================
  // FETCH ARTICLE
  // =====================================================

  Future<void> fetchArticles() async {

  try {

    isLoadingArticles.value = true;

    final response = await http.get(

      Uri.parse(
        '${NetworkConfig.baseUrl}/articles',
      ),
    );

    print(response.body);

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      articles.value = data

          .map(
            (e) => ArticleModel.fromJson(e),
          )

          .toList();

      print(
        "JUMLAH ARTIKEL: ${articles.length}",
      );
    }

  } catch (e) {

    print("ERROR ARTICLE: $e");

  } finally {

    isLoadingArticles.value = false;
  }
}

  // =====================================================
  // SEARCH ARTICLE
  // =====================================================

  Future<void> searchArticle(
  String keyword,
) async {

  try {

    isLoadingArticles.value = true;

    final response = await http.get(

      Uri.parse(
        '${NetworkConfig.baseUrl}/search-realtime/$keyword',
      ),
    );

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      searchResult.value = data

          .map(
            (e) =>
                ArticleModel.fromJson(e),
          )

          .toList();
    }

  } catch (e) {

    print(e);

  } finally {

    isLoadingArticles.value = false;
  }
}

  // =====================================================
  // FETCH WEEKLY TREND
  // =====================================================

  Future<void> fetchWeeklyTrend() async {

  try {

    isLoadingTrend.value = true;

    final response = await http.get(

      Uri.parse(
        '${NetworkConfig.baseUrl}/weekly-trend',
      ),
    );

    print(response.body);

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
}