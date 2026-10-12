import 'package:flutter/material.dart';

class VipBadge extends StatelessWidget {
  final int level;
  final double size;

  const VipBadge({
    super.key,
    required this.level,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 13,
            color: Colors.black87,
          ),
          const SizedBox(width: 2),
          Text(
            'VIP $level',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: size - 3,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
