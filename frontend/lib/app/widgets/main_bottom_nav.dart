import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final navC = Get.find<NavigationController>();

    return Obx(() => BottomNavigationBar(
          currentIndex: navC.currentIndex.value,
          onTap: navC.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E66E7),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline), label: 'Konsultasi'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: 'Chatbot'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Pengaturan'),
          ],
        ));
  }
}