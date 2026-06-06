import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BreathingView extends StatefulWidget {
  const BreathingView({super.key});

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<BreathingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRunning = false;
  bool isMusicPlaying = false;

  String phase = "Siap";
  String selectedMode = "Box Breathing";

  int inhale = 4;
  int hold = 4;
  int exhale = 4;

  final random = Random();

  List<_Particle> particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 0.85, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _generateParticles();
  }

  // 🌿 generate particles
  void _generateParticles() {
    particles = List.generate(30, (i) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0005 + random.nextDouble() * 0.001,
        size: 3 + random.nextDouble() * 3,
      );
    });
  }

  // 🎵 PLAY SOUND (loop hutan)
  Future<void> playMusic() async {
    await _audioPlayer.setAsset('assets/music/hutan.mp3');
    await _audioPlayer.setLoopMode(LoopMode.one);
    await _audioPlayer.play();

    setState(() {
      isMusicPlaying = true;
    });
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();

    setState(() {
      isMusicPlaying = false;
    });
  }

  void setMode(String mode) {
    setState(() {
      selectedMode = mode;

      if (mode == "Box Breathing") {
        inhale = 4;
        hold = 4;
        exhale = 4;
      } else {
        inhale = 4;
        hold = 7;
        exhale = 8;
      }
    });
  }

  void start() {
    setState(() => isRunning = true);
    playMusic(); // 🎵 start ambience
    _runCycle();
  }

  void stop() {
    setState(() {
      isRunning = false;
      phase = "Berhenti";
    });

    stopMusic();
    _controller.stop();
  }

  Future<void> _runCycle() async {
    if (!isRunning) return;

    setState(() => phase = "Tarik Napas");
    _controller.forward(from: 0);
    await Future.delayed(Duration(seconds: inhale));

    if (!isRunning) return;

    setState(() => phase = "Tahan");
    await Future.delayed(Duration(seconds: hold));

    if (!isRunning) return;

    setState(() => phase = "Hembuskan");
    _controller.reverse();
    await Future.delayed(Duration(seconds: exhale));

    if (!isRunning) return;

    _runCycle();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 🌿 animated particles
  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: particles.map((p) {
            p.y -= p.speed;

            if (p.y < 0) {
              p.y = 1;
              p.x = random.nextDouble();
            }

            return Positioned(
              left: p.x * MediaQuery.of(context).size.width,
              top: p.y * MediaQuery.of(context).size.height,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.15),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latihan Pernapasan"),
        backgroundColor: const Color(0xFF2E66E7),
        actions: [
          // 🎵 toggle music
          IconButton(
            icon: Icon(
              isMusicPlaying ? Icons.music_note : Icons.music_off,
            ),
            onPressed: () {
              if (isMusicPlaying) {
                stopMusic();
              } else {
                playMusic();
              }
            },
          )
        ],
      ),

      body: Stack(
        children: [

          // 🌈 background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF4F8FF),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          _buildParticles(),

          // CONTENT
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // MODE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _modeChip("Box Breathing"),
                  const SizedBox(width: 10),
                  _modeChip("4-7-8 Breathing"),
                ],
              ),

              const SizedBox(height: 35),

              // BREATHING CIRCLE
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 190 * _animation.value,
                    height: 190 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2E66E7).withOpacity(0.25),
                          const Color(0xFF2E66E7).withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.air,
                      size: 70,
                      color: Color(0xFF2E66E7),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              Text(
                phase,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "$inhale - $hold - $exhale",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // BUTTON
              ElevatedButton(
                onPressed: isRunning ? stop : start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E66E7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isRunning ? "Stop" : "Mulai",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 MODE CHIP
  Widget _modeChip(String title) {
    final isSelected = selectedMode == title;

    return GestureDetector(
      onTap: () => setMode(title),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E66E7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2E66E7)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2E66E7),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// 🌿 particle model
class _Particle {
  double x;
  double y;
  double speed;
  double size;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}