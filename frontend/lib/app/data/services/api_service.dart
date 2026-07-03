import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article_model.dart';
import '../models/trend_model.dart';

class ApiService {

  static const baseUrl = "https://swan-compactor-revenge.ngrok-free.dev";

  static const _headers = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // =========================================
  // GET ARTICLES
  // =========================================

  static Future<List<ArticleModel>> getArticles() async {

    final response = await http.get(
      Uri.parse('$baseUrl/articles'),
      headers: _headers,
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
      headers: _headers,
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
      headers: _headers,
    );

    final data = jsonDecode(response.body);

    return List<TrendModel>.from(
      data.map((x) => TrendModel.fromJson(x)),
    );
  }
}