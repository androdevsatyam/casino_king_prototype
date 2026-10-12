import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/widgets/animated_coin_counter.dart';
import '../../../core/widgets/vip_badge.dart';
import '../../../state/casino_state.dart';
import '../../auth/auth_modal.dart';

class CasinoHeader extends StatelessWidget {
  final CasinoState state;
  final VoidCallback onDepositTap;

  const CasinoHeader({
    super.key,
    required this.state,
    required this.onDepositTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.user;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: CasinoColors.bgDark,
        border: Border(
          bottom: BorderSide(
            color: CasinoColors.borderGoldSubtle,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Casino Brand Logo
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: CasinoColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: CasinoColors.goldGlow,
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ROYAL TREASURE',
                      style: TextStyle(
                        color: CasinoColors.goldBright,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'VIP CLUB',
                      style: TextStyle(
                        color: CasinoColors.goldDark,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Animated Coin Balance
              AnimatedCoinCounter(
                value: user.coinBalance,
                coinSize: 18,
                style: const TextStyle(
                  color: CasinoColors.goldBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
                onPlusPressed: onDepositTap,
              ),

              const SizedBox(width: 6),

              // Sound Toggle Button
              GestureDetector(
                onTap: () => state.toggleSound(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CasinoColors.bgSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: CasinoColors.borderGoldSubtle),
                  ),
                  child: Icon(
                    state.soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: CasinoColors.gold,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // User Sign In / Profile Quick Bar (matching reference images)
          if (!user.isLoggedIn)
            InkWell(
              onTap: () => showAuthModal(context, state),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: CasinoColors.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CasinoColors.gold,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: CasinoColors.gold,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Sign In / Sign Up',
                      style: TextStyle(
                        color: CasinoColors.goldBright,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: CasinoColors.gold,
                      size: 18,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CasinoColors.bgSecondary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: CasinoColors.borderGoldSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: CasinoColors.gold,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  VipBadge(level: user.vipLevel),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: CasinoColors.winGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CasinoColors.winGreen, width: 0.8),
                    ),
                    child: const Text(
                      'ONLINE',
                      style: TextStyle(
                        color: CasinoColors.winGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
