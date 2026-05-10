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
      backgroundColor: Colors.white,

      // ================= APPBAR =================
      appBar: AppBar(
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
        leading: const Icon(Icons.spa, color: Colors.white),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Column(
              children: [
                Text(
                  "Chat Support",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1B434D),
                  ),
                ),
                SizedBox(height: 5),
                Text(
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
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isSender ? 18 : 0),
          bottomRight: Radius.circular(isSender ? 0 : 18),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
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
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
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
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller.textController,
                  decoration: const InputDecoration(
                    hintText: "Share your thoughts...",
                    border: InputBorder.none,
                    hintStyle:
                        TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Send Button
            GestureDetector(
              onTap: () => controller.sendMessage(),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF2E66E7),
                child: Icon(Icons.send,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}