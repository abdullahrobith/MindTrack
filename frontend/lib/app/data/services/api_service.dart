import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article_model.dart';
import '../models/trend_model.dart';

class ApiService {

  // GANTI DENGAN IP BACKEND KAMU
  static const baseUrl = "http://192.168.123.151:5000";


  // =========================================
  // GET ARTICLES
  // =========================================

  static Future<List<ArticleModel>> getArticles() async {

    final response = await http.get(
      Uri.parse('$baseUrl/articles'),
    );

    final data = jsonDecode(response.body);

    return List<ArticleModel>.from(
      data.map((x) => ArticleModel.fromJson(x)),
    );
  }


  // =========================================
  // SEARCH REALTIME
  // =========================================

  static Future<List<ArticleModel>> searchArticles(
      String keyword) async {

    final response = await http.get(
      Uri.parse(
        '$baseUrl/search-realtime/$keyword',
      ),
    );

    final data = jsonDecode(response.body);

    return List<ArticleModel>.from(
      data.map((x) => ArticleModel.fromJson(x)),
    );
  }


  // =========================================
  // WEEKLY TREND
  // =========================================

  static Future<List<TrendModel>> getWeeklyTrend() async {

    final response = await http.get(
      Uri.parse('$baseUrl/weekly-trend'),
    );

    final data = jsonDecode(response.body);

    return List<TrendModel>.from(
      data.map((x) => TrendModel.fromJson(x)),
    );
  }
}