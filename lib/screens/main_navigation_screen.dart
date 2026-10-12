import 'package:flutter/material.dart';
import '../core/theme/casino_colors.dart';
import '../core/constants/sound_effects.dart';
import '../state/casino_state.dart';
import 'home/home_screen.dart';
import 'promotions/promotions_screen.dart';
import 'earn/earn_money_screen.dart';
import 'profile/profile_screen.dart';
import 'store/coin_store_screen.dart';
import 'lucky_wheel/lucky_wheel_dialog.dart';

class MainNavigationScreen extends StatefulWidget {
  final CasinoState state;

  const MainNavigationScreen({super.key, required this.state});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToStore() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CoinStoreScreen(state: widget.state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        state: widget.state,
        onDepositTap: _navigateToStore,
      ),
      PromotionsScreen(state: widget.state),
      EarnMoneyScreen(state: widget.state),
      ProfileScreen(
        state: widget.state,
        onDepositTap: _navigateToStore,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: _buildCasinoBottomNav(),
    );
  }

  Widget _buildCasinoBottomNav() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: CasinoColors.bgBottomNav,
        border: Border(
          top: BorderSide(
            color: CasinoColors.borderGoldSubtle,
            width: 1.2,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 4 Bottom Bar Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0: Home
              _buildNavItem(
                index: 0,
                icon: Icons.grid_view_rounded,
                label: 'Home',
              ),

              // 1: Promotion
              _buildNavItem(
                index: 1,
                icon: Icons.card_giftcard_rounded,
                label: 'Promotion',
              ),

              // Spacer for Center Lucky Wheel
              const SizedBox(width: 58),

              // 2: Earn Money
              _buildNavItem(
                index: 2,
                icon: Icons.send_rounded,
                label: 'Earn Money',
              ),

              // 3: Account
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'Account',
              ),
            ],
          ),

          // Elevated Center Floating Lucky Wheel Button ("Get ₹200")
          Positioned(
            top: -16,
            child: GestureDetector(
              onTap: () {
                CasinoAudioFeedback.winJackpot();
                showLuckyWheelDialog(context, widget.state);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CasinoColors.goldMetallicGradient,
                      border: Border.all(
                        color: const Color(0xFFFFF7C2),
                        width: 2.5,
                      ),
                      boxShadow: CasinoColors.goldGlow,
                    ),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F172A),
                        ),
                        child: const Icon(
                          Icons.album_rounded,
                          color: CasinoColors.goldBright,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: CasinoColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Get ₹200',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        CasinoAudioFeedback.buttonClick();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? CasinoColors.goldBright : CasinoColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? CasinoColors.goldBright : CasinoColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
