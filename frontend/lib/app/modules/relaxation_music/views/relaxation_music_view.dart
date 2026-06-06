import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class RelaxationMusicView extends StatefulWidget {
  const RelaxationMusicView({super.key});

  @override
  State<RelaxationMusicView> createState() => _RelaxationMusicViewState();
}

class _RelaxationMusicViewState extends State<RelaxationMusicView>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  int? playingIndex;

  late AnimationController _pulseController;

  final musics = [
    {
      "title": "Suara Angin",
      "file": "assets/music/angin.mp3",
      "icon": Icons.water_drop,
    },
    {
      "title": "Suara Perapian",
      "file": "assets/music/api.mp3",
      "icon": Icons.local_fire_department,
    },
    {
      "title": "Suasana Pedesaan",
      "file": "assets/music/desa.mp3",
      "icon": Icons.park,
    },
    {
      "title": "Suasana Pegunungan",
      "file": "assets/music/gunung.mp3",
      "icon": Icons.terrain,
    },
    {
      "title": "Suara Hujan",
      "file": "assets/music/hujan.mp3",
      "icon": Icons.cloud,
    },
    {
      "title": "Suasana Hutan",
      "file": "assets/music/hutan.mp3",
      "icon": Icons.forest,
    },
    {
      "title": "Suara Jangkrik",
      "file": "assets/music/jangkrik.mp3",
      "icon": Icons.nightlight_round,
    },
    {
      "title": "Suasana Laut",
      "file": "assets/music/laut.mp3",
      "icon": Icons.waves,
    },
    {
      "title": "Suara Petir",
      "file": "assets/music/petir.mp3",
      "icon": Icons.thunderstorm,
    },
    {
      "title": "Suasana Sungai",
      "file": "assets/music/sungai.mp3",
      "icon": Icons.water,
    },
  ];

  @override
  void initState() {
    super.initState();

    // 🔁 LOOP MUSIC
    _player.setLoopMode(LoopMode.one);

    // 🎯 ANIMASI PULSE
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.97,
      upperBound: 1.03,
    )..repeat(reverse: true);
  }

  Future<void> playMusic(int index) async {
    final item = musics[index];

    if (playingIndex == index) {
      await _player.pause();
      setState(() => playingIndex = null);
      return;
    }

    await _player.setAsset(item["file"] as String);
    await _player.play();

    setState(() {
      playingIndex = index;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Musik Relaksasi"),
        backgroundColor: const Color(0xFF2E66E7),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFEAF0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: musics.length,

          itemBuilder: (context, index) {
            final item = musics[index];
            final isPlaying = playingIndex == index;

            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale =
                    isPlaying ? _pulseController.value : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 14),

                decoration: BoxDecoration(
                  color: isPlaying
                      ? const Color(0xFF2E66E7)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isPlaying
                          ? const Color(0xFF2E66E7)
                              .withOpacity(0.25)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  leading: CircleAvatar(
                    backgroundColor: isPlaying
                        ? Colors.white
                        : const Color(0xFF2E66E7),
                    child: Icon(
                      item["icon"] as IconData,
                      color: isPlaying
                          ? const Color(0xFF2E66E7)
                          : Colors.white,
                    ),
                  ),

                  title: Text(
                    item["title"] as String,
                    style: TextStyle(
                      color: isPlaying
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    isPlaying
                        ? "🎧 Playing (Loop)"
                        : "Tap to play",
                    style: TextStyle(
                      color: isPlaying
                          ? Colors.white70
                          : Colors.grey,
                    ),
                  ),

                  trailing: IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 36,
                      color: isPlaying
                          ? Colors.white
                          : const Color(0xFF2E66E7),
                    ),
                    onPressed: () => playMusic(index),
                  ),

                  onTap: () => playMusic(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}