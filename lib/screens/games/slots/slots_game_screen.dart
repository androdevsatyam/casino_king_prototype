import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/sound_effects.dart';
import '../../../core/widgets/animated_coin_counter.dart';
import '../../../core/widgets/coin_burst_overlay.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../state/casino_state.dart';

class SlotSymbol {
  final String name;
  final String emoji;
  final double multiplier;
  final Color color;

  const SlotSymbol({
    required this.name,
    required this.emoji,
    required this.multiplier,
    required this.color,
  });
}

class SlotsGameScreen extends StatefulWidget {
  final CasinoState state;

  const SlotsGameScreen({super.key, required this.state});

  @override
  State<SlotsGameScreen> createState() => _SlotsGameScreenState();
}

class _SlotsGameScreenState extends State<SlotsGameScreen>
    with TickerProviderStateMixin {
  final GlobalKey<CoinBurstOverlayState> _burstKey = GlobalKey<CoinBurstOverlayState>();

  static const List<SlotSymbol> _symbols = [
    SlotSymbol(name: 'Crown', emoji: '👑', multiplier: 50.0, color: Color(0xFFFFD700)),
    SlotSymbol(name: 'Diamond', emoji: '💎', multiplier: 25.0, color: Color(0xFF00E5FF)),
    SlotSymbol(name: 'Seven', emoji: '7️⃣', multiplier: 15.0, color: Color(0xFFFF2A42)),
    SlotSymbol(name: 'Gold Bar', emoji: '💰', multiplier: 10.0, color: Color(0xFFFFB300)),
    SlotSymbol(name: 'Bell', emoji: '🔔', multiplier: 5.0, color: Color(0xFFFFD54F)),
    SlotSymbol(name: 'Cherry', emoji: '🍒', multiplier: 3.0, color: Color(0xFFFF1744)),
    SlotSymbol(name: 'Coin', emoji: '🪙', multiplier: 2.0, color: Color(0xFFFFC107)),
  ];

  late List<SlotSymbol> _reel1;
  late List<SlotSymbol> _reel2;
  late List<SlotSymbol> _reel3;

  int _reelIndex1 = 0;
  int _reelIndex2 = 2;
  int _reelIndex3 = 4;

  bool _isSpinning = false;
  bool _autoSpin = false;
  double _betAmount = 20.0;
  double _lastWin = 0.0;
  String _winMessage = '';

  Timer? _spinTimer1;
  Timer? _spinTimer2;
  Timer? _spinTimer3;

  @override
  void initState() {
    super.initState();
    _reel1 = List.from(_symbols)..shuffle();
    _reel2 = List.from(_symbols)..shuffle();
    _reel3 = List.from(_symbols)..shuffle();
  }

  @override
  void dispose() {
    _spinTimer1?.cancel();
    _spinTimer2?.cancel();
    _spinTimer3?.cancel();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    if (widget.state.coinBalance < _betAmount) {
      setState(() => _autoSpin = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins to spin! Recharge in store.'),
          backgroundColor: CasinoColors.hotRed,
        ),
      );
      return;
    }

    final success = widget.state.placeBet(_betAmount);
    if (!success) return;

    setState(() {
      _isSpinning = true;
      _lastWin = 0.0;
      _winMessage = '';
    });

    CasinoAudioFeedback.buttonClick();

    // Spin Reel 1
    _spinTimer1 = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (mounted) {
        setState(() {
          _reelIndex1 = (_reelIndex1 + 1) % _reel1.length;
        });
        CasinoAudioFeedback.spinTick();
      }
    });

    // Spin Reel 2
    _spinTimer2 = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (mounted) {
        setState(() {
          _reelIndex2 = (_reelIndex2 + 1) % _reel2.length;
        });
      }
    });

    // Spin Reel 3
    _spinTimer3 = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (mounted) {
        setState(() {
          _reelIndex3 = (_reelIndex3 + 1) % _reel3.length;
        });
      }
    });

    // Stop Reel 1 after 1200ms
    Future.delayed(const Duration(milliseconds: 1200), () {
      _spinTimer1?.cancel();
      CasinoAudioFeedback.chipBet();
    });

    // Stop Reel 2 after 1700ms
    Future.delayed(const Duration(milliseconds: 1700), () {
      _spinTimer2?.cancel();
      CasinoAudioFeedback.chipBet();
    });

    // Stop Reel 3 after 2200ms & Evaluate win
    Future.delayed(const Duration(milliseconds: 2200), () {
      _spinTimer3?.cancel();
      CasinoAudioFeedback.chipBet();
      _evaluateWin();
    });
  }

  void _evaluateWin() {
    final s1 = _reel1[_reelIndex1];
    final s2 = _reel2[_reelIndex2];
    final s3 = _reel3[_reelIndex3];

    double winMult = 0.0;
    String msg = '';

    // Jackpot: All 3 symbols match!
    if (s1.name == s2.name && s2.name == s3.name) {
      winMult = s1.multiplier;
      msg = 'JACKPOT 3x ${s1.name.toUpperCase()}!';
    }
    // 2 matching symbols
    else if (s1.name == s2.name || s2.name == s3.name || s1.name == s3.name) {
      final matchSym = (s1.name == s2.name || s1.name == s3.name) ? s1 : s2;
      winMult = (matchSym.multiplier * 0.4).clamp(1.5, 20.0);
      msg = 'PAIR WIN: 2x ${matchSym.name}!';
    }
    // Any Gold / Coin combo
    else if (s1.emoji == '🪙' || s2.emoji == '🪙' || s3.emoji == '🪙') {
      winMult = 1.2;
      msg = 'LUCKY COIN RETURN!';
    }

    final totalWin = _betAmount * winMult;

    setState(() {
      _isSpinning = false;
      _lastWin = totalWin;
      _winMessage = msg;
    });

    widget.state.settleBet(
      gameTitle: 'Royal 777 Slots',
      betAmount: _betAmount,
      winAmount: totalWin,
      multiplier: winMult,
    );

    if (totalWin > 0) {
      _burstKey.currentState?.triggerBurst(
        title: msg,
        amount: totalWin,
      );
    }

    // Auto spin handling
    if (_autoSpin) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _autoSpin) {
          _spin();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoinBurstOverlay(
      overlayKey: _burstKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF090B14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF131728),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_7, color: CasinoColors.gold),
              SizedBox(width: 8),
              Text(
                'ROYAL 777 SLOTS',
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
            // Top Jackpot Ticker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF161C33),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, color: CasinoColors.gold, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'PROGRESSIVE JACKPOT: ₹ 2,845,910',
                    style: TextStyle(
                      color: CasinoColors.goldBright,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Vegas Slot Machine Cabinet
                    _buildSlotMachineCabinet(),

                    const SizedBox(height: 16),

                    // Win Status Banner
                    _buildWinBanner(),

                    const SizedBox(height: 16),

                    // Paytable Quick Guide
                    _buildPaytableGuide(),
                  ],
                ),
              ),
            ),

            // Bottom Slot Console Controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotMachineCabinet() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F45), Color(0xFF150F28)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CasinoColors.gold,
          width: 3,
        ),
        boxShadow: CasinoColors.goldGlow,
      ),
      child: Column(
        children: [
          // Blinking Marquee Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (i % 2 == 0) ? CasinoColors.gold : const Color(0xFFFF2A42),
                  boxShadow: [
                    BoxShadow(
                      color: (i % 2 == 0) ? CasinoColors.gold : const Color(0xFFFF2A42),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // 3 Reels Display Frame
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD49B28),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReelColumn(_reel1[_reelIndex1]),
                _buildDivider(),
                _buildReelColumn(_reel2[_reelIndex2]),
                _buildDivider(),
                _buildReelColumn(_reel3[_reelIndex3]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelColumn(SlotSymbol symbol) {
    return Container(
      width: 75,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2538), Color(0xFF121724)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol.emoji,
              style: const TextStyle(fontSize: 38),
            ),
            Text(
              symbol.name,
              style: TextStyle(
                color: symbol.color,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 2,
      height: 70,
      color: CasinoColors.gold.withValues(alpha: 0.5),
    );
  }

  Widget _buildWinBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _lastWin > 0
            ? CasinoColors.winGreen.withValues(alpha: 0.15)
            : CasinoColors.bgDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _lastWin > 0 ? CasinoColors.winGreen : CasinoColors.borderGoldSubtle,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _winMessage.isNotEmpty ? _winMessage : 'SPIN TO WIN ROYAL JACKPOT',
            style: TextStyle(
              color: _lastWin > 0 ? CasinoColors.winGreen : CasinoColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            'WIN: 🪙 ${_lastWin.toStringAsFixed(0)}',
            style: TextStyle(
              color: _lastWin > 0 ? CasinoColors.goldBright : Colors.white60,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaytableGuide() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF11172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👑 PAYTABLE MULTIPLIERS',
            style: TextStyle(
              color: CasinoColors.goldBright,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPayItem('👑 Crown', '50X'),
              _buildPayItem('💎 Gem', '25X'),
              _buildPayItem('7️⃣ Seven', '15X'),
              _buildPayItem('💰 Bar', '10X'),
              _buildPayItem('🪙 Coin', '2X'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayItem(String label, String mult) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        Text(mult, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CasinoColors.goldBright)),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF131A30),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: CasinoColors.gold, width: 1.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Chip bet select
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 20, 50, 100, 250, 500].map((amt) {
                final isSelected = _betAmount == amt.toDouble();
                return GestureDetector(
                  onTap: () {
                    CasinoAudioFeedback.chipBet();
                    setState(() => _betAmount = amt.toDouble());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? CasinoColors.gold : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                      ),
                    ),
                    child: Text(
                      '🪙 $amt',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Controls row: Auto Spin & Spin Button
            Row(
              children: [
                // Auto Spin Toggle
                GestureDetector(
                  onTap: () {
                    CasinoAudioFeedback.buttonClick();
                    setState(() {
                      _autoSpin = !_autoSpin;
                      if (_autoSpin && !_isSpinning) {
                        _spin();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: _autoSpin ? const Color(0xFF00E676) : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _autoSpin ? Colors.white : Colors.white24,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.autorenew,
                          color: _autoSpin ? Colors.black : Colors.white,
                          size: 20,
                        ),
                        Text(
                          'AUTO',
                          style: TextStyle(
                            color: _autoSpin ? Colors.black : Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Main SPIN Button
                Expanded(
                  child: GoldenButton(
                    label: _isSpinning ? 'SPINNING...' : 'SPIN  🪙 ${_betAmount.toInt()}',
                    height: 52,
                    isLoading: _isSpinning,
                    onPressed: _isSpinning ? null : _spin,
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
