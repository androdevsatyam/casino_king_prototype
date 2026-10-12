import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/constants/sound_effects.dart';
import '../../core/widgets/animated_coin_counter.dart';
import '../../core/widgets/coin_burst_overlay.dart';
import '../../core/widgets/golden_button.dart';
import '../../models/coin_package_model.dart';
import '../../state/casino_state.dart';

class CoinStoreScreen extends StatefulWidget {
  final CasinoState state;

  const CoinStoreScreen({super.key, required this.state});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  final GlobalKey<CoinBurstOverlayState> _burstKey = GlobalKey<CoinBurstOverlayState>();
  CoinPackageModel _selectedPackage = CoinPackageModel.packages[1]; // default popular
  String _selectedPaymentMethod = 'UPI';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'UPI', 'subtitle': 'GPay / PhonePe / Paytm', 'icon': Icons.qr_code_2, 'color': Color(0xFF00E676)},
    {'name': 'Cards', 'subtitle': 'Visa, Mastercard, RuPay', 'icon': Icons.credit_card, 'color': Color(0xFF2979FF)},
    {'name': 'Net Banking', 'subtitle': 'All Indian Banks', 'icon': Icons.account_balance, 'color': Color(0xFFFF9100)},
    {'name': 'Crypto USDT', 'subtitle': 'Instant TRC20/BEP20', 'icon': Icons.currency_bitcoin, 'color': Color(0xFFFFD700)},
  ];

  void _handlePurchase() async {
    setState(() => _isProcessing = true);
    CasinoAudioFeedback.buttonClick();

    // Simulate instant payment gateway
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() => _isProcessing = false);

      widget.state.purchaseCoins(_selectedPackage);

      // Trigger Golden Coin Avalanche / Shower Animation!
      _burstKey.currentState?.triggerBurst(
        title: 'PAYMENT SUCCESSFUL!',
        amount: _selectedPackage.totalCoins,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CasinoColors.bgDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: CasinoColors.winGreen),
              const SizedBox(width: 8),
              Text(
                'Added +${_selectedPackage.totalCoins.toInt()} Coins to your vault! 🪙',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoinBurstOverlay(
      overlayKey: _burstKey,
      child: Scaffold(
        backgroundColor: CasinoColors.bgPrimary,
        appBar: AppBar(
          title: const Text('ROYAL COIN VAULT'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedCoinCounter(
                value: widget.state.coinBalance,
                showPlusButton: false,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Treasure Vault Banner
              _buildVaultHeaderBanner(),

              const SizedBox(height: 20),

              // Package Selection Header
              const Text(
                'SELECT COIN RECHARGE PACKAGE',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Grid / List of Coin Packages
              ...CoinPackageModel.packages.map((pkg) => _buildPackageCard(pkg)),

              const SizedBox(height: 20),

              // Payment Channel Selector
              const Text(
                'CHOOSE SECURE PAYMENT GATEWAY',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: _paymentMethods.map((m) {
                  final isSelected = _selectedPaymentMethod == m['name'];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        CasinoAudioFeedback.buttonClick();
                        setState(() => _selectedPaymentMethod = m['name'] as String);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E2D4D) : CasinoColors.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? CasinoColors.gold : Colors.white12,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: isSelected ? CasinoColors.goldGlow : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              m['icon'] as IconData,
                              color: m['color'] as Color,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Big Purchase Button
              GoldenButton(
                label: _isProcessing
                    ? 'PROCESSING PAYMENT...'
                    : 'PAY ₹${_selectedPackage.priceINR.toInt()}  (GET ${_selectedPackage.totalCoins.toInt()} COINS)',
                height: 54,
                isLoading: _isProcessing,
                onPressed: _isProcessing ? null : _handlePurchase,
              ),

              const SizedBox(height: 14),

              const Center(
                child: Text(
                  '🔒 100% Safe & Instant Automated Coin Credit',
                  style: TextStyle(color: CasinoColors.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaultHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1E07), Color(0xFF100B02)],
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
            child: const Icon(Icons.savings_rounded, color: Colors.black87, size: 32),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TREASURE COIN RECHARGE',
                  style: TextStyle(
                    color: CasinoColors.goldBright,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Recharge coins to play all VIP slots, crash, live tables and earn loyalty points!',
                  style: TextStyle(
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

  Widget _buildPackageCard(CoinPackageModel pkg) {
    final isSelected = _selectedPackage.id == pkg.id;

    return GestureDetector(
      onTap: () {
        CasinoAudioFeedback.buttonClick();
        setState(() => _selectedPackage = pkg);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2E3D66), Color(0xFF16213D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF141D33), Color(0xFF0F1629)],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? CasinoColors.gold : CasinoColors.borderMuted,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? CasinoColors.goldGlow : null,
        ),
        child: Row(
          children: [
            // Emoji / Icon
            Text(pkg.iconEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),

            // Package Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pkg.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (pkg.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: pkg.isPopular ? const Color(0xFFFF2A42) : CasinoColors.gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pkg.badge!,
                            style: TextStyle(
                              color: pkg.isPopular ? Colors.white : Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '🪙 ${pkg.coinAmount.toInt()} Coins',
                        style: const TextStyle(
                          color: CasinoColors.goldBright,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (pkg.bonusCoins > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '+${pkg.bonusCoins.toInt()} Bonus',
                          style: const TextStyle(
                            color: CasinoColors.winGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? CasinoColors.goldButtonGradient
                    : const LinearGradient(colors: [Color(0xFF2A3654), Color(0xFF1D263B)]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                ),
              ),
              child: Text(
                '₹${pkg.priceINR.toInt()}',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
