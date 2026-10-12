import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/casino_colors.dart';

class AnimatedCoinCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final double coinSize;
  final bool showPlusButton;
  final VoidCallback? onPlusPressed;

  const AnimatedCoinCounter({
    super.key,
    required this.value,
    this.style,
    this.coinSize = 20,
    this.showPlusButton = true,
    this.onPlusPressed,
  });

  @override
  State<AnimatedCoinCounter> createState() => _AnimatedCoinCounterState();
}

class _AnimatedCoinCounterState extends State<AnimatedCoinCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;
  final NumberFormat _formatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncreasing = widget.value >= _oldValue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CasinoColors.bgDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CasinoColors.gold.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isIncreasing ? CasinoColors.gold : Colors.black).withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Coin Badge
          Container(
            width: widget.coinSize,
            height: widget.coinSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: CasinoColors.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: CasinoColors.gold.withValues(alpha: 0.8),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🪙',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Rolling Coin Value
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                _formatter.format(_animation.value),
                style: widget.style ??
                    const TextStyle(
                      color: CasinoColors.goldBright,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                      fontFamily: 'monospace',
                    ),
              );
            },
          ),

          // Pulsing Add Coins Button
          if (widget.showPlusButton) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: widget.onPlusPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: CasinoColors.goldButtonGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
