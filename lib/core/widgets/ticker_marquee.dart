import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/casino_colors.dart';

class TickerMarquee extends StatefulWidget {
  final List<String> notices;

  const TickerMarquee({
    super.key,
    required this.notices,
  });

  @override
  State<TickerMarquee> createState() => _TickerMarqueeState();
}

class _TickerMarqueeState extends State<TickerMarquee> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && widget.notices.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.notices.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notices.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CasinoColors.bgDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: CasinoColors.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Golden Speaker Icon (from reference images)
          const Icon(
            Icons.volume_up_rounded,
            color: CasinoColors.gold,
            size: 16,
          ),
          const SizedBox(width: 8),

          // Animated text switcher
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.8),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                widget.notices[_currentIndex % widget.notices.length],
                key: ValueKey<int>(_currentIndex),
                style: const TextStyle(
                  color: CasinoColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Small Live Indicator Dot
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CasinoColors.winGreen,
              boxShadow: [
                BoxShadow(
                  color: CasinoColors.winGreen,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
