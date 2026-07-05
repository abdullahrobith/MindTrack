import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/controllers/global_auth_controller.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatbotController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final _storage = const FlutterSecureStorage();

  String get _storageKey {
    final email = Get.find<GlobalAuthController>().currentUser.value?.email ?? 'guest';
    return 'chatbot_messages_$email';
  }

  final messages = <Map<String, dynamic>>[
    {'text': "Halo! Aku MindTrack, asisten virtual kesehatan mentalmu. Ada yang bisa aku bantu hari ini?", 'isSender': false},
  ].obs;
  
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final savedData = await _storage.read(key: _storageKey);
      if (savedData != null) {
        final List<dynamic> decoded = jsonDecode(savedData);
        if (decoded.isNotEmpty) {
          messages.value = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _scrollToBottom();
        }
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> _saveMessages() async {
    try {
      final encoded = jsonEncode(messages);
      await _storage.write(key: _storageKey, value: encoded);
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add({
      'text': text,
      'isSender': true,
    });
    _saveMessages();
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
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({"messages": messagesPayload}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        messages.add({
          'text': data['reply'],
          'isSender': false,
        });
        _saveMessages();
      } else {
        messages.add({
          'text': "Maaf, aku sedang mengalami gangguan koneksi. Coba lagi nanti ya.",
          'isSender': false,
        });
        _saveMessages();
      }
    } catch (e) {
      messages.add({
        'text': "Maaf, terjadi kesalahan. Coba periksa koneksi internetmu.",
        'isSender': false,
      });
      _saveMessages();
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