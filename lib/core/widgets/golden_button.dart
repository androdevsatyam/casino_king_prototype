import 'package:flutter/material.dart';
import '../theme/casino_colors.dart';
import '../constants/sound_effects.dart';

class GoldenButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final bool isLoading;
  final List<Color>? gradientColors;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const GoldenButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.width,
    this.height = 46,
    this.isLoading = false,
    this.gradientColors,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<GoldenButton> createState() => _GoldenButtonState();
}

class _GoldenButtonState extends State<GoldenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward();
    }
  }

  void _onTapCancel() {
    _pressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradientColors != null
        ? LinearGradient(
            colors: widget.gradientColors!,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : CasinoColors.goldButtonGradient;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          if (widget.onPressed != null && !widget.isLoading) {
            CasinoAudioFeedback.buttonClick();
            widget.onPressed!();
          }
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: const Color(0xFFFFF7C2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD49B28).withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              const BoxShadow(
                color: Color(0x66000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black87,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: const Color(0xFF2E1A00)),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.label,
                        style: widget.textStyle ??
                            const TextStyle(
                              color: Color(0xFF261600),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
