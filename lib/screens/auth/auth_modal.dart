import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/widgets/golden_button.dart';
import '../../core/constants/sound_effects.dart';
import '../../state/casino_state.dart';

void showAuthModal(BuildContext context, CasinoState state) {
  CasinoAudioFeedback.buttonClick();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AuthModalSheet(state: state),
  );
}

class _AuthModalSheet extends StatefulWidget {
  final CasinoState state;

  const _AuthModalSheet({required this.state});

  @override
  State<_AuthModalSheet> createState() => _AuthModalSheetState();
}

class _AuthModalSheetState extends State<_AuthModalSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _passController = TextEditingController(text: '••••••••');
  final TextEditingController _usernameController = TextEditingController(text: 'RoyalWinner');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submitAuth(bool isSignup) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      widget.state.login(
        username: isSignup ? _usernameController.text.trim() : 'Player_${_phoneController.text.substring(6)}',
        phone: '+91 ${_phoneController.text.trim()}',
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CasinoColors.bgDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: CasinoColors.winGreen),
              const SizedBox(width: 8),
              Text(
                isSignup ? 'Welcome! +2,000 Bonus Coins credited 🪙' : 'Welcome back, High Roller!',
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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: CasinoColors.bgCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: CasinoColors.gold, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Crown
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.workspace_premium, color: CasinoColors.gold, size: 26),
              SizedBox(width: 8),
              Text(
                'ROYAL CASINO ACCESS',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tabs: Sign In / Sign Up
          Container(
            decoration: BoxDecoration(
              color: CasinoColors.bgDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CasinoColors.borderGoldSubtle),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: CasinoColors.gold,
              indicatorWeight: 3,
              labelColor: CasinoColors.goldBright,
              unselectedLabelColor: CasinoColors.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'SIGN IN'),
                Tab(text: 'REGISTER (+₹200 BONUS)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Form fields
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Sign In Tab
                Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone Number',
                        prefixIcon: Icon(Icons.phone, color: CasinoColors.gold),
                        prefixText: '+91 ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: CasinoColors.gold),
                      ),
                    ),
                  ],
                ),

                // Sign Up Tab
                Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Player Nickname',
                        prefixIcon: Icon(Icons.person, color: CasinoColors.gold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone Number',
                        prefixIcon: Icon(Icons.phone, color: CasinoColors.gold),
                        prefixText: '+91 ',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Action Button
          GoldenButton(
            label: _tabController.index == 0 ? 'ENTER CASINO' : 'CLAIM ₹200 & JOIN',
            isLoading: _isLoading,
            width: double.infinity,
            height: 48,
            onPressed: () => _submitAuth(_tabController.index == 1),
          ),

          const SizedBox(height: 12),
          const Text(
            '🔒 256-Bit SSL Encrypted Gaming & Instant Coin Payouts',
            style: TextStyle(color: CasinoColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
