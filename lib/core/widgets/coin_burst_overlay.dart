import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/casino_colors.dart';

class CoinParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double scale;
  double opacity;
  Color color;

  CoinParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.scale,
    required this.opacity,
    required this.color,
  });
}

class CoinBurstOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<CoinBurstOverlayState> overlayKey;

  const CoinBurstOverlay({
    required this.overlayKey,
    required this.child,
    super.key,
  });

  @override
  CoinBurstOverlayState createState() => CoinBurstOverlayState();
}

class CoinBurstOverlayState extends State<CoinBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CoinParticle> _particles = [];
  final Random _random = Random();
  bool _isPlaying = false;
  String _celebrationTitle = '';
  double _rewardAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isPlaying = false;
            _particles.clear();
          });
        }
      });
  }

  void triggerBurst({
    Offset? origin,
    int particleCount = 45,
    String title = 'MEGA WIN!',
    double amount = 0,
  }) {
    final size = MediaQuery.of(context).size;
    final start = origin ?? Offset(size.width / 2, size.height / 2);

    _particles.clear();
    _celebrationTitle = title;
    _rewardAmount = amount;
    _isPlaying = true;

    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFE57F),
      const Color(0xFFF59E0B),
      const Color(0xFFFFFBEB),
      const Color(0xFFFFC107),
    ];

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 12 + 6;
      _particles.add(
        CoinParticle(
          x: start.dx,
          y: start.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 6, // Initial upward burst
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.4,
          scale: _random.nextDouble() * 0.5 + 0.75,
          opacity: 1.0,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }

    _controller.forward(from: 0.0);
  }

  void _updateParticles() {
    final progress = _controller.value;
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.45; // Gravity
      p.rotation += p.rotationSpeed;
      if (progress > 0.65) {
        p.opacity = ((1.0 - progress) / 0.35).clamp(0.0, 1.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Particle Painter
        if (_isPlaying) ...[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CoinParticlePainter(particles: _particles),
              ),
            ),
          ),

          // Central Celebratory Banner (if title or amount present)
          if (_celebrationTitle.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = (_controller.value < 0.25)
                          ? (_controller.value / 0.25)
                          : (_controller.value > 0.75
                              ? ((1.0 - _controller.value) / 0.25)
                              : 1.0);

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF800020), Color(0xFF1F030C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: CasinoColors.gold,
                              width: 3,
                            ),
                            boxShadow: CasinoColors.goldGlowIntense,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _celebrationTitle,
                                style: const TextStyle(
                                  color: CasinoColors.goldBright,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              if (_rewardAmount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🪙 ', style: TextStyle(fontSize: 22)),
                                    Text(
                                      '+${_rewardAmount.toStringAsFixed(0)} COINS',
                                      style: const TextStyle(
                                        color: CasinoColors.winGreen,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 24,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _CoinParticlePainter extends CustomPainter {
  final List<CoinParticle> particles;

  _CoinParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.opacity <= 0.0) continue;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.scale(p.scale);

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = const Color(0xFF8B5E00).withValues(alpha: p.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // 3D Coin Shape
      canvas.drawCircle(Offset.zero, 13, paint);
      canvas.drawCircle(Offset.zero, 13, borderPaint);

      // Inner coin rim & star/symbol
      final innerPaint = Paint()
        ..color = const Color(0xFFFFF3B0).withValues(alpha: p.opacity * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset.zero, 9, innerPaint);

      // Draw shiny center dot / star
      final centerDotPaint = Paint()
        ..color = const Color(0xFF78350F).withValues(alpha: p.opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 3, centerDotPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CoinParticlePainter oldDelegate) => true;
}
