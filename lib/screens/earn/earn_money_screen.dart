import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/widgets/golden_button.dart';
import '../../core/constants/sound_effects.dart';
import '../../state/casino_state.dart';

class EarnMoneyScreen extends StatelessWidget {
  final CasinoState state;

  const EarnMoneyScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CasinoColors.bgPrimary,
      appBar: AppBar(
        title: const Text('AFFILIATE & EARN MONEY'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Referral Commission Banner
            _buildReferralHeader(),

            const SizedBox(height: 18),

            // User's Unique Referral Code Box
            _buildReferralCodeCard(context),

            const SizedBox(height: 18),

            // Commission Structure Tiers
            _buildCommissionTiers(),

            const SizedBox(height: 18),

            // Total Earnings Statistics Card
            _buildEarningsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2B48), Color(0xFF071424)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CasinoColors.gold, width: 1.5),
        boxShadow: CasinoColors.goldGlow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: CasinoColors.goldGradient,
              boxShadow: CasinoColors.goldGlow,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVITE FRIENDS & EARN',
                  style: TextStyle(
                    color: CasinoColors.goldBright,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get ₹500 instant bonus for every registered friend + up to 10% daily lifetime commission!',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context) {
    const refCode = 'ROYAL889';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CasinoColors.bgCardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR EXCLUSIVE INVITE LINK & CODE',
            style: TextStyle(color: CasinoColors.goldBright, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code, color: CasinoColors.gold, size: 20),
                      SizedBox(width: 8),
                      Text(
                        refCode,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GoldenButton(
                label: 'COPY',
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onPressed: () {
                  CasinoAudioFeedback.buttonClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral Link & Code copied to clipboard!'),
                      backgroundColor: CasinoColors.bgDark,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTiers() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CasinoColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFETIME COMMISSION REBATE TIERS',
            style: TextStyle(color: CasinoColors.goldBright, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTierRow('Tier 1 (Direct Friends)', '10% of bet turnover', Icons.looks_one, CasinoColors.gold),
          const Divider(color: Colors.white12, height: 16),
          _buildTierRow('Tier 2 (Friends\' Friends)', '5% of bet turnover', Icons.looks_two, const Color(0xFF64B5F6)),
          const Divider(color: Colors.white12, height: 16),
          _buildTierRow('Tier 3 (Sub-Agents)', '2% of bet turnover', Icons.looks_3, const Color(0xFFBA68C8)),
        ],
      ),
    );
  }

  Widget _buildTierRow(String title, String rebate, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(rebate, style: const TextStyle(color: CasinoColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Friends Invited: 18', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Active Bettors: 14', style: TextStyle(color: CasinoColors.winGreen, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Unsettled Commission:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                '₹ 4,850.00',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GoldenButton(
            label: 'TRANSFER COMMISSION TO COINS',
            height: 44,
            width: double.infinity,
            onPressed: () {
              CasinoAudioFeedback.winJackpot();
              state.claimDailyBonus(4850);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transferred ₹4,850 commission directly to Coin Balance! 🪙'),
                  backgroundColor: CasinoColors.bgDark,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
