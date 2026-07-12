import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/konsultasi_controller.dart';
import '../../../widgets/main_bottom_nav.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/assessment_data.dart';

class KonsultasiView extends GetView<KonsultasiController> {
  const KonsultasiView({Key? key}) : super(key: key);

  static const _kPrimary = Color(0xFF2E66E7);
  static const _kAccent  = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    Get.find<NavigationController>().currentIndex.value = 1;

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A7DF0), _kPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Logo dihapus, judul diletakkan di tengah
        title: const Text(
          'Konsultasi Hari Ini',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(), // Toggle berada tepat di bawah AppBar
          Expanded(
            child: Obx(() => controller.isVoiceMode.value
                ? _buildVoiceBody()
                : _buildManualBody()),
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Get.isDarkMode ? Colors.black12 : Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        height: 52, // Dibuat sedikit lebih tinggi agar tombol lebih besar/jelas
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Obx(() => Row(
          children: [
            _toggleBtn(
              label: 'Mode Suara', // Teks diperjelas
              icon: Icons.mic_rounded,
              active: controller.isVoiceMode.value,
              onTap: () => controller.switchMode(true),
            ),
            _toggleBtn(
              label: 'Mode Ketik', // Teks diperjelas
              icon: Icons.keyboard_rounded,
              active: !controller.isVoiceMode.value,
              onTap: () => controller.switchMode(false),
            ),
          ],
        )),
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            // Warna latar aktif dibuat lebih mencolok (biru pekat)
            color: active ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20, // Ikon sedikit lebih besar
                color: active ? Colors.white : Colors.grey.shade500,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey.shade500,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  VOICE BODY
  // ═══════════════════════════════════════════════════
  Widget _buildVoiceBody() {
    return Container(
      decoration: BoxDecoration(
        // Memberikan background yang lebih dinamis dengan kombinasi warna
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
            _kPrimary.withOpacity(0.08),
            Get.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Obx(() {
        final started = controller.chatMessages.isNotEmpty ||
            controller.voiceStatus.value != VoiceStatus.idle;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutBack, // Animasi lebih bouncy dan hidup
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: started
              ? _buildVoiceSession(key: const ValueKey('session'))
              : _buildVoiceIntro(key: const ValueKey('intro')),
        );
      }),
    );
  }

  // ── Halaman pembuka sebelum sesi dimulai ────────────
  Widget _buildVoiceIntro({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Orb dengan efek glow di sekitarnya
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kPrimary.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const _BreathingOrb(
                  size: 120, // Sedikit diperbesar
                  icon: Icons.psychology_alt,
                  colors: [_kPrimary, _kAccent],
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_kPrimary, _kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text('Asisten Mindtrack',
                    style: TextStyle(
                        fontSize: 28, // Ukuran font diperbesar
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Text(
                'Cukup bicara, biarkan AI\nmendengarkan dan mencatat untuk Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, 
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56, // Tombol sedikit lebih tinggi
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [_kPrimary, _kAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: _kAccent.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: controller.startVoiceSession,
                      highlightColor: Colors.white.withOpacity(0.2),
                      splashColor: Colors.white.withOpacity(0.2),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_none_rounded, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text('Mulai Sesi Suara',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sesi aktif (chat bubbles + mic dock) ─────────────
  Widget _buildVoiceSession({Key? key}) {
    // Kita kembali menggunakan Column agar mic tidak melayang (meng-overlap) chat
    return Column(
      key: key,
      children: [
        // Asumsi Anda memiliki fungsi _buildProgressBar()
        _buildProgressBar(), 
        
        Expanded(
          child: Obx(() {
            final msgs = controller.chatMessages;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Padding dinormalkan kembali
              itemCount: msgs.length,
              itemBuilder: (_, i) =>
                  _AnimatedBubble(child: _buildBubble(msgs[i])),
            );
          }),
        ),
        
        // Memanggil area mic di bagian paling bawah
        _buildBottomDock(),
      ],
    );
  }

  // ── Area Bawah: Transkrip + Mic (Tanpa Pembungkus) ─────────────
  Widget _buildBottomDock() {
    return SafeArea(
      top: false,
      child: Padding(
        // Padding agar mic dan transkrip memiliki jarak yang pas dari tepi layar
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Garis abu-abu kecil (handle) dihapus karena sudah tidak ada panel
            
            _buildLiveTranscript(),
            _buildMicPanel(),
            _buildSaveButtonIfComplete(),
          ],
        ),
      ),
    );
  }

  // ── Live transcript dengan desain Kapsul Melayang ─────
  Widget _buildLiveTranscript() {
    return Obx(() {
      final live = controller.liveTranscript.value;
      final listening = controller.voiceStatus.value == VoiceStatus.listening;
      
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: (live.isEmpty && !listening)
            ? const SizedBox.shrink()
            : Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Get.isDarkMode 
                      ? const Color(0xFF1E293B).withOpacity(0.8)
                      : const Color(0xFFF0FDF4).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24), // Bentuk pil/kapsul
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: Colors.green.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Menyesuaikan lebar dengan teks
                  children: [
                    const _MiniWaveform(color: Colors.green),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        live.isEmpty ? 'Sedang mendengarkan...' : live,
                        style: TextStyle(
                            color: Get.isDarkMode ? Colors.greenAccent : Colors.green.shade700,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  // ── Chat bubble dengan UI modern ─────────────────────
  Widget _buildBubble(ChatMessage msg) {
    final isAi = msg.isAi;
    return Padding(
      padding: EdgeInsets.only(
          left: isAi ? 0 : 56, // Padding lebih lebar untuk user
          right: isAi ? 56 : 0,
          bottom: 16), // Jarak antar bubble diperlebar
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_kPrimary, _kAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi
                    ? (Get.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white)
                    : null,
                gradient: isAi
                    ? null
                    : const LinearGradient(
                        colors: [_kPrimary, _kAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAi ? 4 : 20),
                  bottomRight: Radius.circular(isAi ? 20 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAi
                        ? Colors.black.withOpacity(0.04)
                        : _kAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isAi
                      ? Get.theme.textTheme.bodyLarge?.color
                      : Colors.white,
                  fontSize: 15, // Sedikit diperbesar agar nyaman dibaca
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel Mic + label status ─────────────────────────
  Widget _buildMicPanel() {
    return Obx(() {
      final status = controller.voiceStatus.value;

      Color micColor;
      IconData micIcon;
      String label;
      bool micEnabled;
      bool pulse;

      switch (status) {
        case VoiceStatus.listening:
          micColor   = const Color(0xFFEF4444); // Merah lebih soft (Tailwind Red-500)
          micIcon    = Icons.stop_rounded;
          label      = 'Ketuk untuk selesai bicara';
          micEnabled = true;
          pulse      = true;
          break;
        case VoiceStatus.thinking:
          micColor   = const Color(0xFFF59E0B); // Amber-500
          micIcon    = Icons.blur_on_rounded; // Icon yang lebih terasa AI
          label      = 'Sedang memproses...';
          micEnabled = false;
          pulse      = true; // Diubah jadi true agar terlihat tidak freeze
          break;
        case VoiceStatus.speaking:
          micColor   = _kAccent;
          micIcon    = Icons.graphic_eq_rounded; // Icon suara
          label      = 'Asisten merespon...';
          micEnabled = false;
          pulse      = true;
          break;
        default:
          micColor   = _kPrimary;
          micIcon    = Icons.mic_rounded;
          label      = 'Ketuk mic untuk berbicara';
          micEnabled = true;
          pulse      = false;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == VoiceStatus.listening) ...[
              const _EqualizerBars(color: Color(0xFFEF4444)),
              const SizedBox(height: 16), // Jarak diubah
            ],
            
            // Bungkus Mic dengan Glow effect sesuai status
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: pulse ? [
                  BoxShadow(
                    color: micColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ] : [],
              ),
              child: _PulsingMicButton(
                color: micColor,
                icon: micIcon,
                enabled: micEnabled,
                pulse: pulse,
                thinking: status == VoiceStatus.thinking,
                onTap: controller.tapMic,
                size: 100, // Sedikit diperkecil agar pas dengan dock baru
              ),
            ),
            
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                label,
                key: ValueKey(label),
                style: TextStyle(
                    color: Get.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, 
                    fontSize: 13, 
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Tombol simpan (muncul saat semua step selesai) ───
  Widget _buildSaveButtonIfComplete() {
    return Obx(() {
      if (controller.currentStep.value < KonsultasiController.totalSteps) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _bottomButton('Simpan Laporan Hari Ini', () async {
          try {
            final result = await controller.submitAssessment();
            Get.toNamed('/hasil', arguments: result);
          } catch (e) {
            Get.snackbar('Belum Bisa Disimpan',
                e.toString().replaceFirst('Exception: ', ''));
          }
        }),
      );
    });
  }

  // ═══════════════════════════════════════════════════
  //  MANUAL BODY (tidak berubah sama sekali)
  // ═══════════════════════════════════════════════════
  Widget _buildManualBody() {
    return Column(
      children: [
        _buildProgressBar(),
        Expanded(
          child: PageView.builder(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: KonsultasiController.totalSteps + 1,
            itemBuilder: (context, index) {
              if (index < KonsultasiController.totalClinical) {
                return _buildClinicalStep(index);
              } else if (index < KonsultasiController.totalSteps) {
                return _buildLifestyleStep(index - KonsultasiController.totalClinical);
              } else {
                return _buildSummaryStep();
              }
            },
          ),
        ),
      ],
    );
  }

  // ── Progress bar (dipakai Manual & Voice) ───────────
  Widget _buildProgressBar() {
    return Obx(() {
      final step  = controller.currentStep.value;
      final total = KonsultasiController.totalSteps;
      final type  = step < KonsultasiController.totalClinical
          ? allClinicalQuestions[step.clamp(0, KonsultasiController.totalClinical - 1)].type
          : null;
      final label = type != null
          ? _instrumentLabel(type)
          : (step < total ? 'Aktivitas Harian' : 'Ringkasan');
      final color = type != null ? _instrumentColor(type) : _kPrimary;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ]),
                Text('${step.clamp(0, total)} / $total',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: controller.progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _instrumentLabel(InstrumentType type) {
    switch (type) {
      case InstrumentType.phq:    return 'Suasana Hati';
      case InstrumentType.gad:    return 'Kecemasan';
      case InstrumentType.stress: return 'Stres';
    }
  }

  Color _instrumentColor(InstrumentType type) {
    switch (type) {
      case InstrumentType.phq:    return _kPrimary;
      case InstrumentType.gad:    return _kAccent;
      case InstrumentType.stress: return const Color(0xFFFF7A45);
    }
  }

  // ── Soal klinis ──────────────────────────────────────
  Widget _buildClinicalStep(int flatIndex) {
    final question = allClinicalQuestions[flatIndex];
    final color    = _instrumentColor(question.type);

    return Obx(() {
      final selected = controller.clinicalAnswers[flatIndex];
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(_instrumentLabel(question.type),
                          style: TextStyle(
                              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 14),
                    Text(question.text,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: Get.theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    const Text(
                        'Selama beberapa hari terakhir, seberapa sering Anda mengalami hal ini?',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 26),
                    ...List.generate(answerOptions.length, (i) {
                      final active = selected == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => controller.answerClinical(flatIndex, i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              color: active ? color : Colors.transparent,
                              border: Border.all(
                                  color: active ? color : Colors.grey.shade300,
                                  width: active ? 0 : 1),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(answerOptions[i],
                                      style: TextStyle(
                                          color: active
                                              ? Colors.white
                                              : Get.theme.textTheme.bodyMedium?.color,
                                          fontWeight: active
                                              ? FontWeight.bold
                                              : FontWeight.normal)),
                                ),
                                if (active)
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            _navRow(showNext: false),
          ],
        ),
      );
    });
  }

  // ── Lifestyle steps ──────────────────────────────────
  Widget _buildLifestyleStep(int li) {
    switch (li) {
      case 0:
        return _lifestyleWrapper(
            title: 'Durasi Tidur', icon: Icons.bedtime_outlined,
            child: Obx(() => _buildSlider(
                controller.sleepHours.value, (v) => controller.sleepHours.value = v)),
            canNext: true);
      case 1:
        return _lifestyleWrapper(
            title: 'Kualitas Tidur', icon: Icons.nightlight_outlined,
            child: _buildChoiceSection(controller.sleepQuality,
                const ['Sangat Buruk', 'Buruk', 'Cukup', 'Baik', 'Sangat Baik']));
      case 2:
        return _lifestyleWrapper(
            title: 'Aktivitas Fisik Hari Ini', icon: Icons.directions_run,
            child: _buildChoiceSection(controller.physicalActivity,
                const ['Tidak Ada', 'Ringan', 'Sedang', 'Aktif', 'Sangat Aktif']));
      case 3:
        return _lifestyleWrapper(
            title: 'Interaksi Sosial Hari Ini', icon: Icons.people_outline,
            child: _buildChoiceSection(controller.socialInteraction,
                const ['Tidak Ada', 'Sedikit', 'Cukup', 'Banyak', 'Sangat Banyak']));
      default:
        return _lifestyleWrapper(
            title: 'Produktivitas Hari Ini', icon: Icons.task_alt,
            child: _buildChoiceSection(controller.productivity,
                const ['Sangat Rendah', 'Rendah', 'Sedang', 'Tinggi', 'Sangat Tinggi']));
    }
  }

  Widget _lifestyleWrapper({
    required String title,
    required IconData icon,
    required Widget child,
    bool canNext = false,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: _kPrimary.withOpacity(0.1),
                    child: Icon(icon, color: _kPrimary),
                  ),
                  const SizedBox(height: 18),
                  Text(title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 26),
                  child,
                ],
              ),
            ),
          ),
          _navRow(showNext: canNext),
        ],
      ),
    );
  }

  Widget _navRow({required bool showNext}) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              if (controller.currentStep.value > 0)
                TextButton.icon(
                    onPressed: controller.prevStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali')),
              const Spacer(),
              if (showNext)
                ElevatedButton(
                  onPressed: controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Lanjut', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ));
  }

  Widget _buildSummaryStep() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: _kPrimary, size: 60),
            const SizedBox(height: 20),
            Text('Semua pertanyaan sudah terisi',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            const Text('Tekan tombol di bawah untuk menyimpan laporan kesehatan mental hari ini.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _bottomButton('Simpan Laporan Hari Ini', () async {
              try {
                final result = await controller.submitAssessment();
                Get.toNamed('/hasil', arguments: result);
              } catch (e) {
                Get.snackbar('Belum Bisa Disimpan',
                    e.toString().replaceFirst('Exception: ', ''));
              }
            }),
            _navRow(showNext: false),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ═══════════════════════════════════════════════════
  Widget _buildSlider(double val, Function(double) onChanged) {
    return Column(
      children: [
        Text('${val.toStringAsFixed(1)} Jam',
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _kPrimary)),
        Slider(
            value: val,
            min: 0,
            max: 12,
            divisions: 20,
            activeColor: _kPrimary,
            onChanged: onChanged),
      ],
    );
  }

  Widget _buildChoiceSection(Rx<int?> selected, List<String> options) {
    return Obx(() => Column(
          children: List.generate(options.length, (index) {
            final active = selected.value == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  selected.value = index;
                  controller.nextStep();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: active ? _kPrimary : Colors.transparent,
                    border: Border.all(
                        color: active ? _kPrimary : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(options[index],
                      style: TextStyle(
                          color: active
                              ? Colors.white
                              : Get.theme.textTheme.bodyMedium?.color,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            );
          }),
        ));
  }

  Widget _bottomButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(colors: [_kPrimary, _kAccent]),
          boxShadow: [
            BoxShadow(
                color: _kPrimary.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onTap,
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  ANIMATED HELPER WIDGETS (khusus mode Voice)
// ═══════════════════════════════════════════════════

class _BreathingOrb extends StatefulWidget {
  final double size;
  final IconData icon;
  final List<Color> colors;

  const _BreathingOrb({
    required this.size,
    required this.icon,
    required this.colors,
  });

  @override
  State<_BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<_BreathingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final scale = 1.0 + (_ctrl.value * 0.08);
        final glow = 0.25 + (_ctrl.value * 0.25);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size * (1.5 + _ctrl.value * 0.3),
              height: widget.size * (1.5 + _ctrl.value * 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.colors.first.withOpacity(0.15 * (1 - _ctrl.value)),
                  width: 1.5,
                ),
              ),
            ),
            Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.colors.first.withOpacity(glow),
                      blurRadius: 26,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.48),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PulsingMicButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool enabled;
  final bool pulse;
  final bool thinking;
  final VoidCallback onTap;
  final double size;

  const _PulsingMicButton({
    required this.color,
    required this.icon,
    required this.enabled,
    required this.pulse,
    required this.thinking,
    required this.onTap,
    this.size = 130,
  });

  @override
  State<_PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<_PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final innerSize = widget.size * 0.62;
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pulse)
                  for (final delay in [0.0, 0.5])
                    Builder(builder: (_) {
                      final localT = (t + delay) % 1.0;
                      return Opacity(
                        opacity: (1 - localT) * 0.5,
                        child: Container(
                          width: innerSize + localT * (widget.size * 0.42),
                          height: innerSize + localT * (widget.size * 0.42),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: widget.color, width: 2),
                          ),
                        ),
                      );
                    }),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(widget.size * 0.16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.color, widget.color.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(widget.pulse ? 0.45 : 0.28),
                        blurRadius: widget.pulse ? 26 : 14,
                        spreadRadius: widget.pulse ? 4 : 0,
                      ),
                    ],
                  ),
                  child: widget.thinking
                      ? RotationTransition(
                          turns: _ctrl,
                          child: Icon(Icons.autorenew_rounded,
                              color: Colors.white, size: widget.size * 0.26),
                        )
                      : Icon(widget.icon, color: Colors.white, size: widget.size * 0.26),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  final Color color;
  const _EqualizerBars({required this.color});

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();
  final _rand = Random();
  late final List<double> _phases =
      List.generate(5, (_) => _rand.nextDouble() * pi * 2);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * pi * 2;
        return SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final h = 6 + (sin(t + _phases[i]).abs() * 22);
              return Container(
                width: 5,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _MiniWaveform extends StatefulWidget {
  final Color color;
  const _MiniWaveform({required this.color});

  @override
  State<_MiniWaveform> createState() => _MiniWaveformState();
}

class _MiniWaveformState extends State<_MiniWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value * pi * 2;
        return SizedBox(
          width: 26,
          height: 18,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final h = 6 + (sin(t + i * 1.4).abs() * 12);
              return Container(
                width: 3,
                height: h,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _AnimatedBubble extends StatefulWidget {
  final Widget child;
  const _AnimatedBubble({required this.child});

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(curved),
        child: widget.child,
      ),
    );
  }
}