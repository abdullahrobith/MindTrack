import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/assessment_data.dart';
import '../../../data/providers/assessment_provider.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../data/rule_based_scorer.dart'; // sesuaikan path

// ══════════════════════════════════════════════════════════════
//  Model satu pesan chat (untuk riwayat UI gelembung)
// ══════════════════════════════════════════════════════════════
class ChatMessage {
  final String text;
  final bool isAi;
  ChatMessage({required this.text, required this.isAi});
}

// ══════════════════════════════════════════════════════════════
//  Status sesi voice
// ══════════════════════════════════════════════════════════════
enum VoiceStatus { idle, listening, thinking, speaking }

class KonsultasiController extends GetxController {
  // ── Mode toggle ─────────────────────────────────────────────
  final isVoiceMode = true.obs;

  // ── Manual mode ─────────────────────────────────────────────
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  static const int totalClinical  = 23;   // 9 PHQ + 7 GAD + 7 Stress
  static const int totalLifestyle = 5;
  static const int totalSteps     = totalClinical + totalLifestyle; // 28

  final RxList<int?> clinicalAnswers = List<int?>.filled(totalClinical, null).obs;

  final sleepHours        = 7.0.obs;
  final RxnInt sleepQuality      = RxnInt();
  final RxnInt physicalActivity  = RxnInt();
  final RxnInt socialInteraction = RxnInt();
  final RxnInt productivity      = RxnInt();

  final AssessmentProvider _assessmentProvider = AssessmentProvider();

  // ── Voice mode state ─────────────────────────────────────────
  final voiceStatus     = VoiceStatus.idle.obs;
  final liveTranscript  = ''.obs;           // teks realtime STT
  final chatMessages    = <ChatMessage>[].obs; // riwayat gelembung chat

  // Engine
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttReady = false;

  // ── Groq API ──────────────────────────────────────────────────
  // Dapatkan API Key di https://console.groq.com/keys
  static const _groqKey   = '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'; 
  static const _groqModel = 'llama-3.3-70b-versatile'; 
  static const _groqUrl   = 'https://api.groq.com/openai/v1/chat/completions';

  // Riwayat percakapan format standar OpenAI/Groq: role 'user' / 'assistant'
  final List<Map<String, String>> _chatHistory = [];

  // Guard agar tidak ada dua permintaan paralel
  bool _processing = false;
  bool _listenConsumed = true; // true = tidak ada sesi listen aktif yang perlu diproses

  // Apakah sesi voice sedang "aktif"
  bool _sessionActive = false;
  StreamSubscription<int>? _tabSub;

  // ══════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ══════════════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _initEngines();
    _watchTabChanges();
  }

  Future<void> _initEngines() async {
    // 1. Pengaturan Dasar TTS
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.48); // Sedikit diperlambat agar lebih empatik
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    // 2. Inisialisasi STT
    _sttReady = await _speech.initialize(
      onStatus: (s) {
        debugPrint('🎙️ STT onStatus: $s (voiceStatus saat ini: ${voiceStatus.value})');
        if ((s == 'notListening' || s == 'done') &&
            voiceStatus.value == VoiceStatus.listening) {
          _onListenDone();
        }
      },
      onError: (err) {
        debugPrint('🎙️ STT onError: $err');
        voiceStatus.value = VoiceStatus.idle;
      },
    );
    debugPrint('🎙️ STT ready: $_sttReady');

    // 3. Panggil fungsi ubah suara secara terpisah TANPA 'await'
    // Sehingga tidak memblokir alur aplikasi jika prosesnya lama.
    _optimizeVoice(); 
  }

  // Fungsi KHUSUS untuk mengubah ke suara "Network"
  Future<void> _optimizeVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return;

      for (var voice in voices) {
        final name = voice['name']?.toString().toLowerCase() ?? '';
        final locale = voice['locale']?.toString().toLowerCase() ?? '';
        
        if (locale.contains('id') && name.contains('network')) {
          await _tts.setVoice({
            "name": voice['name'].toString(),
            "locale": voice['locale'].toString()
          });
          debugPrint('Suara diubah ke natural (network): ${voice['name']}');
          break;
        }
      }
    } catch (e) {
      debugPrint('Gagal mengubah suara, menggunakan suara bawaan. Error: $e');
    }
  }

  void _watchTabChanges() {
  if (!Get.isRegistered<NavigationController>()) return;
  final nav = Get.find<NavigationController>();
  _tabSub = nav.currentIndex.listen((index) {
    if (index != 1) {
      _stopSession();
    } else {
      _resumeSessionIfNeeded(); // ✅ aktifkan lagi saat balik ke tab Konsultasi
    }
  });
}

  void _stopSession() {
  _sessionActive = false;
  _speech.stop();
  _speech.cancel();
  _tts.stop();
  _processing = false;      // ✅ pastikan tidak nyangkut
  _listenConsumed = true;   // ✅ pastikan tidak ada sisa sesi listen lama
  if (voiceStatus.value != VoiceStatus.idle) {
    voiceStatus.value = VoiceStatus.idle;
  }
  liveTranscript.value = '';
}

// Mengaktifkan kembali sesi voice yang sempat dihentikan (karena pindah
// mode/tab), TAPI hanya jika memang ada percakapan yang sedang berjalan
// dan belum selesai. Kalau belum pernah mulai sesi sama sekali, biarkan
// user menekan tombol "Mulai Sesi Suara" seperti biasa.
void _resumeSessionIfNeeded() {
  if (!isVoiceMode.value) return;
  if (_sessionActive) return; // sudah aktif, tidak perlu apa-apa

  final adaPercakapanBerjalan =
      chatMessages.isNotEmpty && currentStep.value < totalSteps;

  if (adaPercakapanBerjalan) {
    _sessionActive = true;
    _processing = false;
    _listenConsumed = true;
    debugPrint('🔄 Sesi voice di-resume, mic siap dipakai lagi.');
  }
}

  void switchMode(bool voice) {
  isVoiceMode.value = voice;
  if (!voice) {
    _stopSession();
  } else {
    _resumeSessionIfNeeded(); // ✅ aktifkan lagi saat balik ke Voice
  }
}

  // ══════════════════════════════════════════════════════════════
  //  VOICE SESSION — START
  // ══════════════════════════════════════════════════════════════
  Future<void> startVoiceSession() async {
    if (!_sttReady) {
      Get.snackbar('Izin Mikrofon', 'Aktifkan izin mikrofon di pengaturan.');
      return;
    }
    _chatHistory.clear();
    chatMessages.clear();
    currentStep.value = 0;
    _sessionActive = true;
    _processing = false; // ⚠️ safety reset kalau sesi sebelumnya nyangkut

    const greeting =
        'Halo! Saya asisten MindTrack. Saya akan menemani Anda '
        'menjawab beberapa pertanyaan seputar perasaan dan aktivitas '
        'hari ini. Ketuk mic saat Anda siap menjawab ya.';
    await _aiSay(greeting);
  }

  // ══════════════════════════════════════════════════════════════
  //  STT — MULAI MENDENGARKAN
  // ══════════════════════════════════════════════════════════════
  Future<void> _startListening() async {
  debugPrint('🎙️ _startListening dipanggil. sttReady=$_sttReady processing=$_processing sessionActive=$_sessionActive');
  if (!_sttReady || _processing || !_sessionActive) {
    debugPrint('🎙️ _startListening DIBATALKAN oleh kondisi guard di atas');
    return;
  }

  // Pastikan sesi STT sebelumnya benar-benar berhenti (bukan cuma stop, tapi cancel)
  await _speech.cancel();

  liveTranscript.value = '';
  _listenConsumed = false; // ✅ sesi listen baru dibuka, siap diproses SEKALI
  voiceStatus.value = VoiceStatus.listening;

  await _speech.listen(
    localeId: 'id_ID',
    listenFor: const Duration(seconds: 30),
    pauseFor: const Duration(seconds: 2),
    onResult: (result) {
      debugPrint('🎙️ onResult: "${result.recognizedWords}" final=${result.finalResult}');
      liveTranscript.value = result.recognizedWords;
      if (result.finalResult && result.recognizedWords.isNotEmpty) {
        _onListenDone();
      }
    },
  );
  debugPrint('🎙️ _speech.listen() sudah dipanggil, menunggu hasil...');
}

  void _onListenDone() {
  debugPrint('🎙️ _onListenDone MULAI. consumed=$_listenConsumed processing=$_processing sessionActive=$_sessionActive transcript="${liveTranscript.value}"');

  // ✅ GUARD UTAMA: kalau sesi listen ini sudah pernah diproses, ABAIKAN
  // Ini mencegah double-trigger dari onResult + onStatus yang sama-sama
  // menganggap sesi sudah "selesai".
  if (_listenConsumed || !_sessionActive) {
    debugPrint('🎙️ _onListenDone DIABAIKAN (sudah dikonsumsi / sesi tidak aktif)');
    return;
  }
  _listenConsumed = true; // ✅ kunci SEGERA sebelum apapun lain, termasuk sebelum cek _processing

  if (_processing) {
    debugPrint('🎙️ _onListenDone DIABAIKAN (masih processing request lain)');
    return;
  }

  _processing = true;
  _speech.stop();

  final transcript = liveTranscript.value.trim();

  if (transcript.isEmpty) {
    debugPrint('🎙️ Transcript kosong, membatalkan.');
    _processing = false;
    voiceStatus.value = VoiceStatus.idle;
    _aiSay('Maaf, saya tidak menangkap jawaban Anda. Ketuk mic dan coba lagi ya.');
    return;
  }

  voiceStatus.value = VoiceStatus.thinking;
  chatMessages.add(ChatMessage(text: transcript, isAi: false));
  liveTranscript.value = '';

  debugPrint('🎙️ Memanggil _sendToGroq dengan transcript: "$transcript"');
  _sendToGroq(transcript);
}

  // ══════════════════════════════════════════════════════════════
  //  KIRIM KE GROQ API
  // ══════════════════════════════════════════════════════════════
  Future<void> _sendToGroq(String userText, {int attempt = 0}) async {
    debugPrint('🤖 _sendToGroq MULAI. userText="$userText" attempt=$attempt processing=$_processing');

    // NOTE: _processing sudah di-set true oleh _onListenDone SEBELUM memanggil ini.
    // Guard di sini hanya untuk mencegah pemanggilan ganda dari sumber lain.
    if (_processing == false) {
      debugPrint('🤖 _sendToGroq DIBATALKAN karena processing sudah false (tidak seharusnya terjadi)');
      return;
    }

    try {
      debugPrint('🤖 Masuk try block. currentStep=${currentStep.value}');

      String ctx = '';
      int? preScore;
      double? preSleepHours;

      if (currentStep.value < totalClinical) {
        final q = allClinicalQuestions[currentStep.value];
        final label = _instrumentLabel(q.type);
        preScore = RuleBasedScorer.scoreClinical(userText);
        debugPrint('🤖 [Klinis] step=${currentStep.value} preScore=$preScore');

        ctx = 'Instrumen: $label. '
            'Pertanyaan klinis berikutnya (WAJIB disampaikan dengan makna & isi '
            'yang SAMA PERSIS seperti aslinya — boleh dibungkus kalimat pengantar '
            'yang natural, TAPI JANGAN mengubah atau mengganti pertanyaannya): '
            '"${q.text}". '
            'Skala internal (JANGAN disebut ke user): 0=Tidak sama sekali, '
            '1=Beberapa hari, 2=Lebih dari separuh hari, 3=Hampir setiap hari.';

        if (preScore != null) {
          ctx += ' Skor jawaban user SUDAH ditentukan sistem: $preScore. '
              'Jangan hitung ulang, langsung pakai nilai ini di field "skor".';
        }
      } else if (currentStep.value < totalSteps) {
        final li = currentStep.value - totalClinical;
        final lq = lifestyleQuestions[li];

        if (li == 0) {
          preSleepHours = RuleBasedScorer.scoreSleepHours(userText);
          debugPrint('🤖 [Lifestyle:tidur] preSleepHours=$preSleepHours');
        } else {
          preScore = RuleBasedScorer.scoreFivePoint(userText);
          debugPrint('🤖 [Lifestyle] li=$li preScore=$preScore');
        }

        ctx = 'Pertanyaan gaya hidup berikutnya (WAJIB disampaikan dengan makna '
            'yang SAMA, boleh dirangkai natural): "${lq.text}". '
            'Opsi internal (JANGAN disebut ke user): '
            '${lq.options.asMap().entries.map((e) => '${e.key}=${e.value}').join(', ')}.';

        if (preScore != null) {
          ctx += ' Skor jawaban user SUDAH ditentukan sistem: $preScore. '
              'Jangan hitung ulang, langsung pakai nilai ini di field "skor".';
        }
        if (preSleepHours != null) {
          ctx += ' Durasi tidur user SUDAH ditentukan sistem: $preSleepHours jam. '
              'Isi field "jam_tidur" dengan nilai ini persis.';
        }
      } else {
        ctx = 'Semua pertanyaan selesai. Buat kalimat penutup yang hangat tanpa diagnosis.';
      }

      final systemPrompt = '''
Kamu adalah konselor AI MindTrack yang hangat dan empatik, berbicara dalam Bahasa Indonesia natural.
Tugasmu: merespons jawaban user dengan 1–2 kalimat empati yang mengalir,
lalu menyambung ke pertanyaan berikutnya SECARA NATURAL — variasikan gaya
pengantarnya setiap kali agar tidak terasa seperti membaca skrip, tapi isi
pertanyaan yang disampaikan HARUS tetap sama persis maknanya dengan yang
diberikan di konteks.
JANGAN menyebutkan skala angka atau pilihan ganda ke user.
JANGAN mengarang pertanyaan baru di luar yang diberikan di konteks.

WAJIB MENGEMBALIKAN HANYA FORMAT JSON SEPERTI INI TANPA TEKS LAIN:
{
  "skor": 0,
  "respon": "kalimat respons + pertanyaan berikutnya"
}

Jika skor/durasi tidur sudah disebutkan "SUDAH ditentukan sistem" di konteks,
gunakan nilai itu apa adanya, jangan hitung ulang sendiri.
Jika belum ditentukan, tentukan sendiri berdasarkan rubrik ini:
- Klinis: 0=tidak pernah, 1=beberapa hari, 2=lebih dari separuh hari, 3=hampir setiap hari.
- Gaya hidup: integer 0–4 sesuai indeks opsi (khusus durasi tidur pakai field "jam_tidur").
Konteks saat ini: $ctx
''';

      if (attempt == 0) {
        _chatHistory.add({'role': 'user', 'content': userText});
      }

      final List<Map<String, String>> messagesPayload = [
        {'role': 'system', 'content': systemPrompt},
        ..._chatHistory,
      ];

      debugPrint('🤖 Mengirim request ke Groq... (jumlah pesan di history: ${_chatHistory.length})');

      final res = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Authorization': 'Bearer $_groqKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _groqModel,
          'messages': messagesPayload,
          'response_format': {'type': 'json_object'},
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      ).timeout(const Duration(seconds: 40));

      debugPrint('🤖 Response diterima. statusCode=${res.statusCode}');

      if (res.statusCode != 200) {
        debugPrint('🤖 Body error: ${res.body}');
        throw Exception('API Error ${res.statusCode}: ${res.body}');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      String raw = body['choices'][0]['message']['content'] as String;
      debugPrint('🤖 Raw content dari Groq: $raw');

      final startIndex = raw.indexOf('{');
      final endIndex = raw.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        raw = raw.substring(startIndex, endIndex + 1);
      } else {
        throw Exception('Gagal menemukan format JSON di respons AI: $raw');
      }

      final json = jsonDecode(raw) as Map<String, dynamic>;
      final String aiReply = (json['respon'] as String?)?.trim() ?? '';
      if (aiReply.isEmpty) throw Exception('Respons AI kosong di dalam JSON');

      debugPrint('🤖 aiReply berhasil di-parse: "$aiReply"');

      _applyScore(json, preScore: preScore, preSleepHours: preSleepHours);

      if (currentStep.value < totalSteps) currentStep.value++;

      _chatHistory.add({'role': 'assistant', 'content': aiReply});
      _processing = false;

      if (!_sessionActive) {
        debugPrint('🤖 Sesi sudah tidak aktif, membatalkan _aiSay.');
        return;
      }
      debugPrint('🤖 Memanggil _aiSay...');
      await _aiSay(aiReply);
    } catch (e) {
      debugPrint('🚨 [ERROR GROQ API] 🚨');
      debugPrint('Attempt: $attempt');
      debugPrint('Error detail: $e');
      debugPrint('=====================');

      _processing = false;
      if (!_sessionActive) return;

      if (attempt < 1) {
        debugPrint('🤖 Mencoba ulang (retry)...');
        await Future.delayed(const Duration(milliseconds: 1000));
        await _sendToGroq(userText, attempt: attempt + 1);
        return;
      }

      voiceStatus.value = VoiceStatus.idle;
      const fallback = 'Maaf, sistem saya sedang mengalami gangguan sesaat. Ketuk mic dan ulangi jawaban Anda ya.';
      await _aiSay(fallback);
    }
  }

  void _applyScore(Map<String, dynamic> json, {int? preScore, double? preSleepHours}) {
    final step = currentStep.value;
    if (step < totalClinical) {
      final raw = preScore ?? (json['skor'] as num?)?.toInt() ?? 0;
      clinicalAnswers[step] = raw.clamp(0, 3).toInt();
    } else if (step < totalSteps) {
      final li = step - totalClinical;
      if (li == 0) {
        final hours = preSleepHours ??
            (json['jam_tidur'] as num?)?.toDouble() ??
            (json['skor'] as num?)?.toDouble() ??
            7.0;
        sleepHours.value = hours.clamp(0.0, 12.0);
      } else {
        final raw = preScore ?? (json['skor'] as num?)?.toInt() ?? 0;
        final s = raw.clamp(0, 4).toInt();
        switch (li) {
          case 1: sleepQuality.value      = s; break;
          case 2: physicalActivity.value  = s; break;
          case 3: socialInteraction.value = s; break;
          case 4: productivity.value      = s; break;
        }
      }
    }
  }

  Future<void> _aiSay(String text) async {
    debugPrint('🔊 _aiSay MULAI: "$text"');
    chatMessages.add(ChatMessage(text: text, isAi: true));
    voiceStatus.value = VoiceStatus.speaking;
    try {
      await _tts.speak(text);
      debugPrint('🔊 _tts.speak selesai.');
    } catch (e) {
      debugPrint('🔊 Error saat TTS speak: $e');
    }
    voiceStatus.value = VoiceStatus.idle;
    debugPrint('🔊 voiceStatus dikembalikan ke idle.');
  }

  void tapMic() {
    debugPrint('👆 tapMic ditekan. status saat ini: ${voiceStatus.value}');
    if (voiceStatus.value == VoiceStatus.listening) {
      _speech.stop();
    } else if (voiceStatus.value == VoiceStatus.idle) {
      _startListening();
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  LABEL HELPERS
  // ══════════════════════════════════════════════════════════════
  String _instrumentLabel(InstrumentType t) {
    switch (t) {
      case InstrumentType.phq:    return 'Suasana Hati (PHQ-9)';
      case InstrumentType.gad:    return 'Kecemasan (GAD-7)';
      case InstrumentType.stress: return 'Stres (DASS-21)';
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  MANUAL MODE HELPERS
  // ══════════════════════════════════════════════════════════════
  List<int> get phqAnswers    => clinicalAnswers.sublist(0,  9).map((e) => e ?? 0).toList();
  List<int> get gadAnswers    => clinicalAnswers.sublist(9,  16).map((e) => e ?? 0).toList();
  List<int> get stressAnswers => clinicalAnswers.sublist(16, 23).map((e) => e ?? 0).toList();

  void answerClinical(int flatIndex, int value) {
    clinicalAnswers[flatIndex] = value;
    _autoAdvance();
  }

  bool _isAdvancing = false;
  void _autoAdvance() {
    if (_isAdvancing) return;
    _isAdvancing = true;
    Future.delayed(const Duration(milliseconds: 200), () {
      _isAdvancing = false;
      if (currentStep.value < totalSteps) nextStep();
    });
  }

  void nextStep() {
    if (currentStep.value < totalSteps) {
      currentStep.value++;
      if (pageController.hasClients) {
        pageController.animateToPage(currentStep.value,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      if (pageController.hasClients) {
        pageController.animateToPage(currentStep.value,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  double get progress => currentStep.value / totalSteps;

  bool get isComplete =>
      !clinicalAnswers.contains(null) &&
      sleepQuality.value      != null &&
      physicalActivity.value  != null &&
      socialInteraction.value != null &&
      productivity.value      != null;

  void resetAssessment() {
    clinicalAnswers.value = List<int?>.filled(totalClinical, null);
    sleepHours.value = 7.0;
    sleepQuality.value      = null;
    physicalActivity.value  = null;
    socialInteraction.value = null;
    productivity.value      = null;
    currentStep.value = 0;
    chatMessages.clear();
    _chatHistory.clear();
    liveTranscript.value = '';
    voiceStatus.value = VoiceStatus.idle;
    _processing = false;
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  void resetForAccountSwitch() {
    _stopSession();
    resetAssessment();
  }

  Future<Map<String, dynamic>> submitAssessment() async {
    if (!isComplete) {
      throw Exception('Masih ada pertanyaan yang belum terisi. Silakan periksa kembali.');
    }
    final result = await _assessmentProvider.submitAssessment(
      phqAnswers:       phqAnswers,
      gadAnswers:       gadAnswers,
      stressAnswers:    stressAnswers,
      sleepHours:       sleepHours.value,
      sleepQuality:     sleepQuality.value      ?? 0,
      physicalActivity: physicalActivity.value  ?? 0,
      socialInteraction:socialInteraction.value ?? 0,
      productivity:     productivity.value      ?? 0,
    );
    resetAssessment();
    return result;
  }

  @override
  void onClose() {
    _stopSession();
    _tabSub?.cancel();
    pageController.dispose();
    super.onClose();
  }
}