import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/widgets/vip_badge.dart';
import '../../core/widgets/golden_button.dart';
import '../../core/constants/sound_effects.dart';
import '../../state/casino_state.dart';
import '../auth/auth_modal.dart';

class ProfileScreen extends StatelessWidget {
  final CasinoState state;
  final VoidCallback onDepositTap;

  const ProfileScreen({
    super.key,
    required this.state,
    required this.onDepositTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = state.user;

    return Scaffold(
      backgroundColor: CasinoColors.bgPrimary,
      appBar: AppBar(
        title: const Text('PLAYER ACCOUNT & VIP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2B4B), Color(0xFF10172B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CasinoColors.gold, width: 1.5),
                boxShadow: CasinoColors.goldGlow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: CasinoColors.goldGradient,
                          boxShadow: CasinoColors.goldGlow,
                        ),
                        child: Center(
                          child: Text(
                            user.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                VipBadge(level: user.vipLevel),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.phone,
                              style: const TextStyle(
                                color: CasinoColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!user.isLoggedIn)
                        TextButton(
                          onPressed: () => showAuthModal(context, state),
                          child: const Text('SIGN IN', style: TextStyle(color: CasinoColors.gold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // VIP Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'VIP Tier ${user.vipLevel} Privileges',
                            style: const TextStyle(color: CasinoColors.goldBright, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${user.vipPoints} / ${(user.vipLevel * 500)} Points',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ((user.vipPoints % 500) / 500.0).clamp(0.05, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(CasinoColors.gold),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financial Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CasinoColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CasinoColors.borderGoldSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('COIN BALANCE', '🪙 ${user.coinBalance.toInt()}', CasinoColors.goldBright),
                  Container(width: 1, height: 35, color: Colors.white12),
                  _buildStatColumn('TOTAL BETS', '🪙 ${user.totalBet.toInt()}', Colors.white70),
                  Container(width: 1, height: 35, color: Colors.white12),
                  _buildStatColumn('TOTAL WON', '🪙 ${user.totalWon.toInt()}', CasinoColors.winGreen),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions: Recharge & Withdraw
            Row(
              children: [
                Expanded(
                  child: GoldenButton(
                    label: 'RECHARGE COINS',
                    icon: Icons.add_circle_outline,
                    height: 46,
                    onPressed: onDepositTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.outbox, color: CasinoColors.gold, size: 18),
                    label: const Text('WITHDRAW'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CasinoColors.gold,
                      side: const BorderSide(color: CasinoColors.gold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      CasinoAudioFeedback.buttonClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Withdrawal request submitted! Processing via IMPS/UPI.'),
                          backgroundColor: CasinoColors.bgDark,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Betting Activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT BETTING ACTIVITY',
                  style: TextStyle(
                    color: CasinoColors.goldBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${state.betRecords.length} Rounds',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (state.betRecords.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CasinoColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Center(
                  child: Text(
                    'No bets placed yet. Play Aviator or Slots to start!',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.betRecords.length > 5 ? 5 : state.betRecords.length,
                itemBuilder: (context, idx) {
                  final rec = state.betRecords[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CasinoColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: rec.isWin ? CasinoColors.winGreen.withValues(alpha: 0.3) : Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.gameTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              'Bet: 🪙 ${rec.betAmount.toInt()}  |  ${rec.multiplier.toStringAsFixed(2)}x',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          rec.isWin ? '+🪙 ${rec.winAmount.toInt()}' : '-🪙 ${rec.betAmount.toInt()}',
                          style: TextStyle(
                            color: rec.isWin ? CasinoColors.winGreen : const Color(0xFFFF2A42),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Logout Button (if logged in)
            if (user.isLoggedIn)
              TextButton.icon(
                icon: const Icon(Icons.logout, color: CasinoColors.textMuted, size: 16),
                label: const Text('Log Out', style: TextStyle(color: CasinoColors.textMuted)),
                onPressed: () {
                  CasinoAudioFeedback.buttonClick();
                  state.logout();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: valColor, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
