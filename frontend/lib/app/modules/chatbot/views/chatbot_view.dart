import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chatbot_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SET INDEX NAVBAR = 2 (Chatbot)
    Get.find<NavigationController>().currentIndex.value = 2;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E66E7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MindTrack Chatbot',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      // ================= BODY =================
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              children: [
                Text(
                  "Chat Support",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Get.theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Ceritakan apa yang kamu rasakan hari ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final chat = controller.messages[index];
                    return _buildChatBubble(
                      chat['text'],
                      chat['isSender'],
                    );
                  },
                )),
          ),

          // Input
          _buildInputArea(),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  // ================= CHAT BUBBLE =================
  Widget _buildChatBubble(String text, bool isSender) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            _bubbleContainer(text, isSender),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Color(0xFFF1F1F1),
              child: Icon(Icons.support_agent,
                  size: 12, color: Colors.grey),
            ),
          ] else ...[
            _bubbleContainer(text, isSender),
          ],
        ],
      ),
    );
  }

  Widget _bubbleContainer(String text, bool isSender) {
    return Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSender
            ? (Get.isDarkMode ? const Color(0xFF1A237E) : const Color(0xFFE3F2FD))
            : (Get.isDarkMode ? const Color(0xFF263238) : const Color(0xFFE8F5E9)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isSender ? 18 : 0),
          bottomRight: Radius.circular(isSender ? 0 : 18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Get.isDarkMode ? Colors.white : Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Input Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
                  decoration: const InputDecoration(
                    hintText: "Share your thoughts...",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintStyle:
                        TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Send Button
            Obx(() => GestureDetector(
              onTap: controller.isLoading.value ? null : () => controller.sendMessage(),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: controller.isLoading.value ? Colors.grey : const Color(0xFF2E66E7),
                child: controller.isLoading.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            )),
          ],
        ),
      ),
    );
  }
}