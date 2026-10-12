import 'package:flutter/material.dart';
import '../theme/casino_colors.dart';
import '../constants/sound_effects.dart';

class FloatingSupportButton extends StatefulWidget {
  final VoidCallback? onTap;

  const FloatingSupportButton({super.key, this.onTap});

  @override
  State<FloatingSupportButton> createState() => _FloatingSupportButtonState();
}

class _FloatingSupportButtonState extends State<FloatingSupportButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showSupportDialog(BuildContext context) {
    CasinoAudioFeedback.buttonClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CasinoColors.bgCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CasinoColors.gold, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: CasinoColors.gold, size: 28),
            SizedBox(width: 10),
            Text(
              '24/7 VIP Support',
              style: TextStyle(color: CasinoColors.goldBright, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our dedicated concierge team is available round-the-clock for deposit, withdrawal, and gameplay assistance.',
              style: TextStyle(color: CasinoColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildSupportRow(Icons.chat, 'Live Chat Concierge', 'Average response: 30 secs'),
            const SizedBox(height: 10),
            _buildSupportRow(Icons.telegram, 'Telegram Official VIP', '@RoyalTreasureVIP'),
            const SizedBox(height: 10),
            _buildSupportRow(Icons.email, 'Email Support', 'support@royaltreasure.vip'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: CasinoColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connected to VIP Live Concierge Agent!'),
                  backgroundColor: CasinoColors.bgDark,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CasinoColors.gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CasinoColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: CasinoColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CasinoColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CasinoColors.gold.withValues(alpha: 0.2 + (_pulseController.value * 0.3)),
                blurRadius: 10 + (_pulseController.value * 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              _showSupportDialog(context);
            }
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF1E2D4A), Color(0xFF0C1425)],
              ),
              border: Border.all(
                color: CasinoColors.gold,
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.headset_mic_rounded,
                  color: CasinoColors.goldBright,
                  size: 24,
                ),
                Positioned(
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '24/7',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 8,
                      ),
                    ),
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
