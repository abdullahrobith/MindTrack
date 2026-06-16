import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pengaturan_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import 'edit_profil_view.dart';
import 'ubah_password_view.dart';

class PengaturanView extends GetView<PengaturanController> {
  const PengaturanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildSectionTitle('Akun'),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () => Get.to(() => const EditProfilView()),
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Ubah Password',
              onTap: () => Get.to(() => const UbahPasswordView()),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Tampilan'),
            _buildThemeToggle(),
            const SizedBox(height: 20),
            _buildSectionTitle('Lainnya'),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {
                Get.defaultDialog(
                  title: 'Tentang MindTrack',
                  middleText: 'Versi 1.0.0\nAplikasi pelacak kesehatan mental.',
                  textConfirm: 'Tutup',
                  confirmTextColor: Colors.white,
                  onConfirm: () => Get.back(),
                );
              },
            ),
            const SizedBox(height: 40),
            _buildLogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final user = controller.auth.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF2E66E7).withOpacity(0.1),
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 40, color: Color(0xFF2E66E7))
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E66E7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E66E7)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    );
  }

  Widget _buildThemeToggle() {
    return Obx(() {
      final isDark = controller.auth.isDarkMode.value;
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E66E7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF2E66E7)),
        ),
        title: const Text('Tema Gelap', style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: isDark,
          activeColor: const Color(0xFF2E66E7),
          onChanged: (val) {
            controller.auth.changeTheme(val ? 'dark' : 'light');
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      );
    });
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Get.defaultDialog(
            title: "Logout",
            middleText: "Apakah Anda yakin ingin keluar?",
            textCancel: "Batal",
            textConfirm: "Ya, Keluar",
            confirmTextColor: Colors.white,
            buttonColor: Colors.red,
            cancelTextColor: Colors.red,
            onConfirm: () => controller.logout(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
