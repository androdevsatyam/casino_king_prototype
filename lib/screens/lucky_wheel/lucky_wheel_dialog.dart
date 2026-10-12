import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/constants/sound_effects.dart';
import '../../core/widgets/golden_button.dart';
import '../../state/casino_state.dart';

void showLuckyWheelDialog(BuildContext context, CasinoState state) {
  showDialog(
    context: context,
    builder: (ctx) => _LuckyWheelDialog(state: state),
  );
}

class _LuckyWheelDialog extends StatefulWidget {
  final CasinoState state;

  const _LuckyWheelDialog({required this.state});

  @override
  State<_LuckyWheelDialog> createState() => _LuckyWheelDialogState();
}

class _LuckyWheelDialogState extends State<_LuckyWheelDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final List<Map<String, dynamic>> _prizes = [
    {'label': '₹200', 'coins': 200.0, 'color': Color(0xFFFFD700), 'textColor': Colors.black},
    {'label': '₹50', 'coins': 50.0, 'color': Color(0xFF1E3A8A), 'textColor': Colors.white},
    {'label': '₹500', 'coins': 500.0, 'color': Color(0xFFDC2626), 'textColor': Colors.white},
    {'label': '₹20', 'coins': 20.0, 'color': Color(0xFF047857), 'textColor': Colors.white},
    {'label': '₹100', 'coins': 100.0, 'color': Color(0xFF7C3AED), 'textColor': Colors.white},
    {'label': '₹10', 'coins': 10.0, 'color': Color(0xFFD97706), 'textColor': Colors.white},
    {'label': '₹300', 'coins': 300.0, 'color': Color(0xFF0284C7), 'textColor': Colors.white},
    {'label': '₹25', 'coins': 25.0, 'color': Color(0xFF9333EA), 'textColor': Colors.white},
  ];

  bool _isSpinning = false;
  double _currentAngle = 0.0;
  double _targetAngle = 0.0;
  Map<String, dynamic>? _wonPrize;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wonPrize = null;
    });

    CasinoAudioFeedback.buttonClick();

    // Pick prize index
    final random = Random();
    final prizeIndex = random.nextInt(_prizes.length);
    final sectorAngle = (2 * pi) / _prizes.length;

    // Additional full rotations (5-8 full spins)
    final fullSpins = 6 * 2 * pi;
    // Align pointer (top center = 3 * pi / 2 or pointing at top)
    final targetSectorCenter = (prizeIndex * sectorAngle) + (sectorAngle / 2);
    _targetAngle = _currentAngle + fullSpins + (2 * pi - (targetSectorCenter % (2 * pi)));

    _spinAnimation = Tween<double>(begin: _currentAngle, end: _targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _spinController.reset();
    _spinController.forward();

    // Ticking audio simulation
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isSpinning) {
        timer.cancel();
      } else {
        CasinoAudioFeedback.spinTick();
      }
    });

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentAngle = _targetAngle % (2 * pi);
        final prize = _prizes[prizeIndex];

        setState(() {
          _isSpinning = false;
          _wonPrize = prize;
        });

        CasinoAudioFeedback.winJackpot();
        widget.state.claimDailyBonus(prize['coins'] as double);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E2846), Color(0xFF0F1527)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: CasinoColors.gold,
            width: 2.5,
          ),
          boxShadow: CasinoColors.goldGlowIntense,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Crown & Title
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium, color: CasinoColors.gold, size: 28),
                SizedBox(width: 8),
                Text(
                  'LUCKY TREASURE WHEEL',
                  style: TextStyle(
                    color: CasinoColors.goldBright,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Spin every day to claim up to ₹500 free bonus coins!',
              style: TextStyle(color: CasinoColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Rotating Wheel Container
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Golden Rim
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CasinoColors.goldMetallicGradient,
                      boxShadow: CasinoColors.goldGlow,
                      border: Border.all(color: const Color(0xFFFFFDE7), width: 3),
                    ),
                  ),

                  // Animated Rotating Canvas
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isSpinning ? _spinAnimation.value : _currentAngle,
                        child: child,
                      );
                    },
                    child: CustomPaint(
                      size: const Size(240, 240),
                      painter: _WheelPainter(prizes: _prizes),
                    ),
                  ),

                  // Center Gold Hub
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CasinoColors.goldGradient,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'SPIN',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Top Pointer Arrow
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 32,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFFF2A42),
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Won Prize Celebration Box
            if (_wonPrize != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CasinoColors.winGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CasinoColors.winGreen, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉 ', style: TextStyle(fontSize: 18)),
                    Text(
                      'CONGRATS! WON ${_wonPrize!['label']} COINS!',
                      style: const TextStyle(
                        color: CasinoColors.winGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Spin Button
            GoldenButton(
              label: _isSpinning ? 'SPINNING...' : 'FREE DAILY SPIN',
              isLoading: _isSpinning,
              width: double.infinity,
              height: 48,
              onPressed: _isSpinning ? null : _spinWheel,
            ),
            const SizedBox(height: 8),

            // Close dialog
            TextButton(
              onPressed: _isSpinning ? null : () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: CasinoColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * sweepAngle;
      final prize = prizes[i];

      final paint = Paint()
        ..color = prize['color'] as Color
        ..style = PaintingStyle.fill;

      // Draw Sector
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw Sector Border
      final borderPaint = Paint()
        ..color = CasinoColors.gold.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw Text on sector
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + (sweepAngle / 2));

      final textSpan = TextSpan(
        text: prize['label'] as String,
        style: TextStyle(
          color: prize['textColor'] as Color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(radius * 0.55, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}
