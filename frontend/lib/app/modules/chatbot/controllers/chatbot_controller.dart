import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  final messages = <Map<String, dynamic>>[
    {'text': "Halo! Aku MindTrack, asisten virtual kesehatan mentalmu. Ada yang bisa aku bantu hari ini?", 'isSender': false},
  ].obs;
  
  final isLoading = false.obs;

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add({
      'text': text,
      'isSender': true,
    });
    textController.clear();
    _scrollToBottom();

    isLoading.value = true;

    try {
      final messagesPayload = messages.map((m) {
        return {
          "role": m['isSender'] ? "user" : "assistant",
          "content": m['text'],
        };
      }).toList();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chatbot/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"messages": messagesPayload}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        messages.add({
          'text': data['reply'],
          'isSender': false,
        });
      } else {
        messages.add({
          'text': "Maaf, aku sedang mengalami gangguan koneksi. Coba lagi nanti ya.",
          'isSender': false,
        });
      }
    } catch (e) {
      messages.add({
        'text': "Maaf, terjadi kesalahan. Coba periksa koneksi internetmu.",
        'isSender': false,
      });
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}