import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/widgets/golden_button.dart';
import '../../core/constants/sound_effects.dart';
import '../../state/casino_state.dart';

class PromotionsScreen extends StatelessWidget {
  final CasinoState state;

  const PromotionsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.bgPrimary,
      appBar: AppBar(
        title: const Text('PROMOTIONS & BONUSES'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Daily Check-In Streak Card
          _buildDailyCheckInCard(context),

          const SizedBox(height: 14),

          // 100% First Deposit Bonus
          _buildPromoCard(
            title: '100% FIRST RECHARGE MATCH',
            tag: 'NEW PLAYERS',
            description: 'Double your deposit coins on your initial recharge up to ₹10,000!',
            gradient: const [Color(0xFF581C87), Color(0xFF1E0533)],
            icon: Icons.savings,
            buttonText: 'RECHARGE NOW',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bonus active! Select any coin package in store to double it.'),
                  backgroundColor: CasinoColors.bgDark,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Daily Loss Cashback 10%
          _buildPromoCard(
            title: 'DAILY 10% VIP CASHBACK',
            tag: 'AUTOMATIC REBATE',
            description: 'Get up to 10% of daily net game play automatically returned every midnight.',
            gradient: const [Color(0xFF064E3B), Color(0xFF022C22)],
            icon: Icons.replay_circle_filled,
            buttonText: 'VIEW DETAILS',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          // Aviator Flight Tournament
          _buildPromoCard(
            title: 'AVIATOR HIGH FLYER RACE',
            tag: '₹100,000 PRIZE POOL',
            description: 'Climb the multiplier leaderboards by hitting the highest cashouts this week.',
            gradient: const [Color(0xFF881337), Color(0xFF3B0715)],
            icon: Icons.flight_takeoff,
            buttonText: 'JOIN RACE',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckInCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF281C06), Color(0xFF100B02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CasinoColors.gold, width: 1.5),
        boxShadow: CasinoColors.goldGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: CasinoColors.gold, size: 22),
              const SizedBox(width: 8),
              const Text(
                '7-DAY DAILY CHECK-IN STREAK',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CasinoColors.winGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DAY 3 ACTIVE',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Streak 7 Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isToday = day == 3;
              final isClaimed = day < 3;

              return Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? CasinoColors.gold
                      : (isClaimed ? const Color(0xFF064E3B) : Colors.black45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday ? Colors.white : Colors.white24,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'D$day',
                      style: TextStyle(
                        color: isToday ? Colors.black : Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isClaimed ? '✓' : '🪙${day * 50}',
                      style: TextStyle(
                        color: isToday ? Colors.black : CasinoColors.goldBright,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          GoldenButton(
            label: 'CLAIM TODAY\'S 🪙150 BONUS',
            height: 38,
            onPressed: () {
              CasinoAudioFeedback.winJackpot();
              state.claimDailyBonus(150);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Claimed +150 Daily Streak Bonus! 🪙'),
                  backgroundColor: CasinoColors.bgDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String tag,
    required String description,
    required List<Color> gradient,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
              border: Border.all(color: CasinoColors.gold, width: 1),
            ),
            child: Icon(icon, color: CasinoColors.goldBright, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: CasinoColors.gold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
