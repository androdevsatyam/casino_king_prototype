import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/sound_effects.dart';
import '../../../core/widgets/animated_coin_counter.dart';
import '../../../core/widgets/coin_burst_overlay.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../state/casino_state.dart';

class RouletteGameScreen extends StatefulWidget {
  final CasinoState state;

  const RouletteGameScreen({super.key, required this.state});

  @override
  State<RouletteGameScreen> createState() => _RouletteGameScreenState();
}

class _RouletteGameScreenState extends State<RouletteGameScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CoinBurstOverlayState> _burstKey = GlobalKey<CoinBurstOverlayState>();

  late AnimationController _wheelController;
  final Map<String, double> _placedBets = {};
  double _selectedChip = 50.0;
  bool _isSpinning = false;
  int _winningNumber = 7;
  String _winningColor = 'RED';
  double _lastPayout = 0.0;
  final Random _random = Random();

  final List<int> _redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _placeBetOn(String betKey) {
    if (_isSpinning) return;

    if (widget.state.coinBalance < _selectedChip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins to place bet!'),
          backgroundColor: CasinoColors.hotRed,
        ),
      );
      return;
    }

    final success = widget.state.placeBet(_selectedChip);
    if (success) {
      setState(() {
        _placedBets[betKey] = (_placedBets[betKey] ?? 0.0) + _selectedChip;
      });
      CasinoAudioFeedback.chipBet();
    }
  }

  void _clearBets() {
    if (_isSpinning || _placedBets.isEmpty) return;

    // Refund coins back
    double refundTotal = 0;
    _placedBets.forEach((key, val) => refundTotal += val);
    widget.state.claimDailyBonus(refundTotal);

    setState(() {
      _placedBets.clear();
    });
    CasinoAudioFeedback.buttonClick();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    if (_placedBets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please place chips on the table first!'),
          backgroundColor: CasinoColors.bgDark,
        ),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _lastPayout = 0.0;
    });

    CasinoAudioFeedback.buttonClick();

    // Wheel spin animation
    _wheelController.reset();
    _wheelController.forward();

    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!_isSpinning) {
        timer.cancel();
      } else {
        CasinoAudioFeedback.spinTick();
      }
    });

    // Conclude spin after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      final winNum = _random.nextInt(37); // 0 to 36
      final isRed = _redNumbers.contains(winNum);
      final winCol = winNum == 0 ? 'GREEN' : (isRed ? 'RED' : 'BLACK');

      double totalWin = 0.0;
      double totalBet = 0.0;

      _placedBets.forEach((key, amt) {
        totalBet += amt;
        if (key == 'RED' && isRed && winNum != 0) totalWin += amt * 2;
        if (key == 'BLACK' && !isRed && winNum != 0) totalWin += amt * 2;
        if (key == 'EVEN' && winNum != 0 && winNum % 2 == 0) totalWin += amt * 2;
        if (key == 'ODD' && winNum % 2 != 0) totalWin += amt * 2;
        if (key == 'DRAGON' && winNum > 18) totalWin += amt * 2;
        if (key == 'TIGER' && winNum <= 18 && winNum != 0) totalWin += amt * 2;
        if (key == 'NUMBER_$winNum') totalWin += amt * 36;
      });

      setState(() {
        _isSpinning = false;
        _winningNumber = winNum;
        _winningColor = winCol;
        _lastPayout = totalWin;
        _placedBets.clear();
      });

      widget.state.settleBet(
        gameTitle: 'Royal Roulette Live',
        betAmount: totalBet,
        winAmount: totalWin,
        multiplier: totalBet > 0 ? (totalWin / totalBet) : 0,
      );

      if (totalWin > 0) {
        _burstKey.currentState?.triggerBurst(
          title: 'ROULETTE WIN $winNum ($winCol)!',
          amount: totalWin,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoinBurstOverlay(
      overlayKey: _burstKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF071C14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B291D),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.track_changes, color: CasinoColors.gold),
              SizedBox(width: 8),
              Text(
                'ROYAL ROULETTE',
                style: TextStyle(
                  color: CasinoColors.goldBright,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
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
        body: Column(
          children: [
            // Top Roulette Wheel Graphic Display
            _buildRouletteWheelView(),

            // Last Winning Number Result
            _buildResultRibbon(),

            // Interactive Casino Green Felt Betting Table
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _buildBettingFelt(),
              ),
            ),

            // Bottom Console (Chips & Spin)
            _buildChipsAndActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouletteWheelView() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF133E2E), Color(0xFF071A12)],
        ),
        border: Border(bottom: BorderSide(color: CasinoColors.borderGoldSubtle)),
      ),
      child: Center(
        child: RotationTransition(
          turns: _wheelController,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: CasinoColors.goldMetallicGradient,
              boxShadow: CasinoColors.goldGlow,
              border: Border.all(color: const Color(0xFFFFF9C4), width: 3),
            ),
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F172A),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: CasinoColors.goldGradient,
                    ),
                    child: Center(
                      child: Text(
                        '$_winningNumber',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRibbon() {
    Color badgeColor = CasinoColors.winGreen;
    if (_winningColor == 'RED') badgeColor = const Color(0xFFFF2A42);
    if (_winningColor == 'BLACK') badgeColor = Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('RESULT: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_winningNumber ($_winningColor)',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          if (_lastPayout > 0)
            Text(
              'PAYOUT: +🪙 ${_lastPayout.toInt()}',
              style: const TextStyle(
                color: CasinoColors.winGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBettingFelt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3325),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // High Level Choices: RED, BLACK, EVEN, ODD
          Row(
            children: [
              _buildFeltSpot('RED', 'RED 2X', const Color(0xFFD32F2F)),
              const SizedBox(width: 8),
              _buildFeltSpot('BLACK', 'BLACK 2X', const Color(0xFF212121)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFeltSpot('EVEN', 'EVEN 2X', const Color(0xFF1B5E20)),
              const SizedBox(width: 8),
              _buildFeltSpot('ODD', 'ODD 2X', const Color(0xFF1B5E20)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFeltSpot('DRAGON', 'DRAGON (19-36)', const Color(0xFFC2410C)),
              const SizedBox(width: 8),
              _buildFeltSpot('TIGER', 'TIGER (1-18)', const Color(0xFFB45309)),
            ],
          ),
          const SizedBox(height: 12),

          // Lucky Hot Numbers Grid (Select individual number for 36X!)
          const Text(
            'LUCKY NUMBERS (PAY 36X)',
            style: TextStyle(
              color: CasinoColors.goldBright,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [7, 8, 9, 11, 17, 21, 28, 33].map((number) {
              final isRed = _redNumbers.contains(number);
              final key = 'NUMBER_$number';
              final betVal = _placedBets[key] ?? 0;

              return GestureDetector(
                onTap: () => _placeBetOn(key),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isRed ? const Color(0xFFB71C1C) : Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: betVal > 0 ? CasinoColors.gold : Colors.white24,
                      width: betVal > 0 ? 2 : 1,
                    ),
                    boxShadow: betVal > 0 ? CasinoColors.goldGlow : null,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (betVal > 0)
                          Text(
                            '🪙${betVal.toInt()}',
                            style: const TextStyle(
                              color: CasinoColors.goldBright,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeltSpot(String key, String label, Color bgColor) {
    final betVal = _placedBets[key] ?? 0;

    return Expanded(
      child: GestureDetector(
        onTap: () => _placeBetOn(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: betVal > 0 ? CasinoColors.gold : Colors.white24,
              width: betVal > 0 ? 2 : 1,
            ),
            boxShadow: betVal > 0 ? CasinoColors.goldGlow : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              if (betVal > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '🪙 ${betVal.toInt()} PLACED',
                  style: const TextStyle(
                    color: CasinoColors.goldBright,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipsAndActions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF091E15),
        border: Border(top: BorderSide(color: CasinoColors.gold, width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Chip Denomination Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 25, 50, 100, 500].map((chip) {
                final isSelected = _selectedChip == chip.toDouble();

                return GestureDetector(
                  onTap: () {
                    CasinoAudioFeedback.chipBet();
                    setState(() => _selectedChip = chip.toDouble());
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? CasinoColors.goldGradient
                          : const LinearGradient(
                              colors: [Color(0xFF2A4237), Color(0xFF14241D)],
                            ),
                      border: Border.all(
                        color: isSelected ? Colors.white : CasinoColors.gold,
                        width: 2,
                      ),
                      boxShadow: isSelected ? CasinoColors.goldGlow : null,
                    ),
                    child: Center(
                      child: Text(
                        '$chip',
                        style: TextStyle(
                          color: isSelected ? Colors.black : CasinoColors.goldBright,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Clear & Spin Row
            Row(
              children: [
                OutlinedButton(
                  onPressed: _placedBets.isNotEmpty && !_isSpinning ? _clearBets : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('CLEAR'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GoldenButton(
                    label: _isSpinning ? 'SPINNING ROULETTE...' : 'SPIN WHEEL',
                    isLoading: _isSpinning,
                    onPressed: _isSpinning ? null : _spinWheel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
