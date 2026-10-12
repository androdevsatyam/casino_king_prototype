import 'package:flutter/material.dart';
import '../theme/casino_colors.dart';

class LuxuryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasGlow;
  final List<Color>? gradientColors;

  const LuxuryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 14,
    this.onTap,
    this.hasGlow = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [
            const Color(0xFF161F38),
            const Color(0xFF0F1629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasGlow ? CasinoColors.gold : CasinoColors.borderGoldSubtle,
          width: hasGlow ? 1.5 : 1.0,
        ),
        boxShadow: hasGlow
            ? CasinoColors.goldGlow
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
