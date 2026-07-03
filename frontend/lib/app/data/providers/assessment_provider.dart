import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/network_config.dart';

class AssessmentProvider {

  static const _baseHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ==========================
  // SUBMIT ASSESSMENT
  // ==========================

  Future<Map<String, dynamic>> submitAssessment({
    required List<int> phqAnswers,
    required List<int> gadAnswers,
    required List<int> stressAnswers,
    required double sleepHours,
    required int sleepQuality,
    required int physicalActivity,
    required int socialInteraction,
    required int productivity,
  }) async {

    print("TOKEN: ${NetworkConfig.token}");

    final payload = {
      "phq_answers": phqAnswers,
      "gad_answers": gadAnswers,
      "stress_answers": stressAnswers,
      "sleep_hours": sleepHours,
      "sleep_quality": sleepQuality,
      "physical_activity": physicalActivity,
      "social_interaction": socialInteraction,
      "productivity": productivity,
    };

    print("PAYLOAD YANG DIKIRIM:");
    print(payload);

    final response = await http.post(
      Uri.parse(
        '${NetworkConfig.baseUrl}/assessment/submit',
      ),
      headers: {
        ..._baseHeaders,
        'Authorization': 'Bearer ${NetworkConfig.token}',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  // ==========================
  // RIWAYAT ASSESSMENT
  // ==========================

  Future<List<dynamic>> getHistory() async {

    final response = await http.get(
      Uri.parse(
        '${NetworkConfig.baseUrl}/assessment/history',
      ),
      headers: {
        ..._baseHeaders,
        'Authorization': 'Bearer ${NetworkConfig.token}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Gagal mengambil riwayat assessment",
    );
  }
}