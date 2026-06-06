import 'dart:math';
import 'package:flutter/material.dart';

class AffirmationView extends StatefulWidget {
  const AffirmationView({super.key});

  @override
  State<AffirmationView> createState() => _AffirmationViewState();
}

class _AffirmationViewState extends State<AffirmationView>
    with SingleTickerProviderStateMixin {
  final List<String> affirmations = [
    "Saya cukup, bahkan saat tidak produktif",
    "Saya aman di tempat saya berada sekarang",
    "Saya tidak harus terburu-buru dalam hidup",
    "Saya boleh merasa lelah dan tetap berharga",
    "Hari ini tidak harus sempurna",
    "Saya memilih untuk lebih tenang",
    "Saya tidak perlu membandingkan diri",
    "Apa yang saya rasakan adalah valid",
    "Saya sedang bertumbuh, meski perlahan",
    "Saya percaya hidup sedang membentuk saya",
    "Saya bisa melewati ini, pelan-pelan",
    "Tidak semua hal harus saya kendalikan",
  ];

  int index = 0;

  final random = Random();
  List<_Particle> particles = [];

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _generateParticles();
  }

  void _generateParticles() {
    particles = List.generate(25, (i) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.0003 + random.nextDouble() * 0.0008,
        size: 2 + random.nextDouble() * 3,
      );
    });
  }

  void next() {
    setState(() {
      index = (index + 1) % affirmations.length;
    });
    _controller.forward(from: 0);
  }

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
                  color: const Color(0xFF6C7CE7).withOpacity(0.08),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),

      body: GestureDetector(
        onTap: next,
        child: Stack(
          children: [

            // 🌿 SOFT GRADIENT GLOW BACKGROUND
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFFEAF0FF),
                    Color(0xFFF6F8FF),
                    Color(0xFFFFFFFF),
                  ],
                ),
              ),
            ),

            // 🌿 particles
            _buildParticles(),

            // 🧘 content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _animation.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _animation.value) * 12),
                        child: Text(
                          affirmations[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.8,

                            // ✨ typography upgrade
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,

                            // elegan calm color
                            color: Color(0xFF1F2430),

                            // lebih “soft reading feel”
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // hint kecil
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                "tap anywhere to continue",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
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