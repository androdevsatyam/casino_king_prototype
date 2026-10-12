import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/sound_effects.dart';
import '../../../core/widgets/animated_coin_counter.dart';
import '../../../core/widgets/coin_burst_overlay.dart';
import '../../../core/widgets/golden_button.dart';
import '../../../state/casino_state.dart';

enum LudoPlayer { red, green }

class LudoGameScreen extends StatefulWidget {
  final CasinoState state;

  const LudoGameScreen({super.key, required this.state});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen>
    with TickerProviderStateMixin {
  final GlobalKey<CoinBurstOverlayState> _burstKey = GlobalKey<CoinBurstOverlayState>();

  late AnimationController _diceController;
  late AnimationController _tokenHopController;

  bool _gameStarted = false;
  double _betAmount = 50.0;
  int _playerRedScore = 0;
  int _playerGreenScore = 0;
  final int _targetScore = 30; // Quick race to 30 points

  int _currentDiceValue = 6;
  bool _isRolling = false;
  LudoPlayer _turn = LudoPlayer.red;
  String _gameMessage = 'Place your bet and start the 2-Player Ludo Duel!';
  final Random _random = Random();

  // Positions on virtual track (0 to 28)
  int _redToken1Pos = 0;
  int _greenToken1Pos = 0;

  @override
  void initState() {
    super.initState();
    _diceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tokenHopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    _tokenHopController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (widget.state.coinBalance < _betAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins to start Ludo duel!'),
          backgroundColor: CasinoColors.hotRed,
        ),
      );
      return;
    }

    final success = widget.state.placeBet(_betAmount);
    if (!success) return;

    CasinoAudioFeedback.buttonClick();

    setState(() {
      _gameStarted = true;
      _playerRedScore = 0;
      _playerGreenScore = 0;
      _redToken1Pos = 0;
      _greenToken1Pos = 0;
      _turn = LudoPlayer.red;
      _gameMessage = 'Your turn! Tap the dice to roll.';
    });
  }

  void _rollDice() {
    if (!_gameStarted || _isRolling || _turn != LudoPlayer.red) return;

    _executeDiceRoll(LudoPlayer.red);
  }

  void _executeDiceRoll(LudoPlayer player) {
    setState(() {
      _isRolling = true;
    });

    CasinoAudioFeedback.spinTick();
    _diceController.forward(from: 0.0);

    Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      final rolled = _random.nextInt(6) + 1;
      CasinoAudioFeedback.chipBet();

      setState(() {
        _currentDiceValue = rolled;
        _isRolling = false;
      });

      _advancePlayer(player, rolled);
    });
  }

  void _advancePlayer(LudoPlayer player, int steps) {
    _tokenHopController.forward(from: 0.0);

    if (player == LudoPlayer.red) {
      // Advance Red token
      setState(() {
        _redToken1Pos += steps;
        _playerRedScore += steps * 2;
        _gameMessage = 'You rolled a $steps! Moved +$steps spots.';

        // Knockout check on green token
        if (_redToken1Pos == _greenToken1Pos && _redToken1Pos > 0) {
          _greenToken1Pos = 0;
          _playerRedScore += 10;
          _gameMessage = 'KNOCKOUT! 💥 Captured Green token (+10 bonus pts)!';
          CasinoAudioFeedback.winJackpot();
        }
      });

      // Check Red Victory
      if (_playerRedScore >= _targetScore) {
        _handleGameEnd(isUserWin: true);
        return;
      }

      // If rolled 6, user gets another turn!
      if (steps == 6) {
        setState(() {
          _gameMessage = 'ROLLED A 6! 🎲 Roll again!';
        });
        return;
      }

      // Switch to Opponent
      setState(() {
        _turn = LudoPlayer.green;
        _gameMessage = 'VIP Challenger is rolling...';
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _gameStarted && _turn == LudoPlayer.green) {
          _executeDiceRoll(LudoPlayer.green);
        }
      });
    } else {
      // Advance Green token (AI opponent)
      setState(() {
        _greenToken1Pos += steps;
        _playerGreenScore += steps * 2;
        _gameMessage = 'Challenger rolled a $steps!';

        // Knockout check on red token
        if (_greenToken1Pos == _redToken1Pos && _greenToken1Pos > 0) {
          _redToken1Pos = 0;
          _playerGreenScore += 10;
          _gameMessage = 'Challenger captured your token! ⚠️';
          CasinoAudioFeedback.crashLoss();
        }
      });

      // Check Green Victory
      if (_playerGreenScore >= _targetScore) {
        _handleGameEnd(isUserWin: false);
        return;
      }

      // If Green rolled 6, they roll again
      if (steps == 6) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _gameStarted && _turn == LudoPlayer.green) {
            _executeDiceRoll(LudoPlayer.green);
          }
        });
        return;
      }

      // Switch back to Red
      setState(() {
        _turn = LudoPlayer.red;
        _gameMessage = 'Your turn! Tap the dice to roll.';
      });
    }
  }

  void _handleGameEnd({required bool isUserWin}) {
    final double winPayout = isUserWin ? (_betAmount * 1.95) : 0.0;

    setState(() {
      _gameStarted = false;
      _gameMessage = isUserWin
          ? '🏆 ROYAL LUDO CHAMPION! Won ₹${winPayout.toInt()} Coins!'
          : 'Challenger reached target first. Better luck next roll!';
    });

    widget.state.settleBet(
      gameTitle: 'Royal Ludo Cash',
      betAmount: _betAmount,
      winAmount: winPayout,
      multiplier: isUserWin ? 1.95 : 0.0,
    );

    if (isUserWin) {
      _burstKey.currentState?.triggerBurst(
        title: 'LUDO VICTORY!',
        amount: winPayout,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CoinBurstOverlay(
      overlayKey: _burstKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F1D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.casino, color: CasinoColors.gold),
              SizedBox(width: 8),
              Text(
                'ROYAL LUDO CASH',
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
            // Top Tournament Header / Score Board
            _buildScoreBoardHeader(),

            // Status Announcer Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black45,
              child: Row(
                children: [
                  Icon(
                    _turn == LudoPlayer.red ? Icons.sports_esports : Icons.hourglass_top,
                    color: _turn == LudoPlayer.red ? const Color(0xFFFF3366) : const Color(0xFF00E676),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _gameMessage,
                      style: TextStyle(
                        color: _turn == LudoPlayer.red ? CasinoColors.goldBright : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Main Royal Ludo Board Viewport
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildRoyalLudoBoard(),
                    const SizedBox(height: 12),
                    _buildDiceRollingArena(),
                  ],
                ),
              ),
            ),

            // Bottom Console: Bet Selection & Start
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF131E35),
        border: Border(bottom: BorderSide(color: CasinoColors.borderGoldSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Red Profile (You)
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF2A42),
                  border: Border.all(
                    color: _turn == LudoPlayer.red ? CasinoColors.gold : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: _turn == LudoPlayer.red ? CasinoColors.goldGlow : null,
                ),
                child: const Center(
                  child: Text('🔴', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOU (RED)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(
                    '$_playerRedScore / $_targetScore PTS',
                    style: const TextStyle(color: Color(0xFFFF3366), fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),

          // Center Prize Pool Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: CasinoColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: CasinoColors.goldGlow,
            ),
            child: Column(
              children: [
                const Text('PRIZE POOL', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                Text(
                  '🪙 ${(_betAmount * 1.95).toInt()}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ],
            ),
          ),

          // Player Green Profile (VIP Challenger)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('VIP BOT (GREEN)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(
                    '$_playerGreenScore / $_targetScore PTS',
                    style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676),
                  border: Border.all(
                    color: _turn == LudoPlayer.green ? CasinoColors.gold : Colors.white24,
                    width: 2,
                  ),
                  boxShadow: _turn == LudoPlayer.green ? CasinoColors.goldGlow : null,
                ),
                child: const Center(
                  child: Text('🟢', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalLudoBoard() {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF0A101D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CasinoColors.gold, width: 2.5),
        boxShadow: CasinoColors.goldGlow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 Corner Quadrants (Red, Green, Blue, Yellow Casino felt stations)
          // Top-Left: Sapphire Blue Station
          Positioned(
            top: 10,
            left: 10,
            child: _buildLudoCornerStation('BLUE', const Color(0xFF1E3A8A)),
          ),
          // Top-Right: Emerald Green Station (Challenger)
          Positioned(
            top: 10,
            right: 10,
            child: _buildLudoCornerStation('GREEN (VIP)', const Color(0xFF047857), hasActivePawn: true, isGreen: true),
          ),
          // Bottom-Left: Ruby Red Station (You)
          Positioned(
            bottom: 10,
            left: 10,
            child: _buildLudoCornerStation('RED (YOU)', const Color(0xFF991B1B), hasActivePawn: true, isGreen: false),
          ),
          // Bottom-Right: Amber Gold Station
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildLudoCornerStation('GOLD', const Color(0xFFB45309)),
          ),

          // Central Home Trophy Vault
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: CasinoColors.goldMetallicGradient,
              boxShadow: CasinoColors.goldGlow,
              border: Border.all(color: const Color(0xFFFFFDE7), width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFF451A03), size: 30),
                  Text(
                    'WIN',
                    style: TextStyle(
                      color: Color(0xFF451A03),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Race Progress Rings around Center
          Positioned(
            bottom: 84,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrackProgressDot('🔴 You Pos: $_redToken1Pos', const Color(0xFFFF2A42)),
                const SizedBox(width: 14),
                _buildTrackProgressDot('🟢 VIP Pos: $_greenToken1Pos', const Color(0xFF00E676)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLudoCornerStation(String label, Color color, {bool hasActivePawn = false, bool isGreen = false}) {
    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.gold.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: hasActivePawn
                  ? Text(
                      isGreen ? '🟢' : '🔴',
                      style: const TextStyle(fontSize: 24),
                    )
                  : const Icon(Icons.star, color: Colors.white30, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackProgressDot(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildDiceRollingArena() {
    final bool canRoll = _gameStarted && !_isRolling && _turn == LudoPlayer.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CasinoColors.borderGoldSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 3D Animated Dice Widget
          GestureDetector(
            onTap: canRoll ? _rollDice : null,
            child: AnimatedBuilder(
              animation: _diceController,
              builder: (context, child) {
                final angle = _diceController.value * 2 * pi * 3;
                return Transform.rotate(
                  angle: angle,
                  child: child,
                );
              },
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFFDE7),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CasinoColors.gold.withValues(alpha: canRoll ? 0.7 : 0.3),
                      blurRadius: canRoll ? 16 : 6,
                      spreadRadius: canRoll ? 2 : 0,
                    ),
                    const BoxShadow(
                      color: Colors.black54,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildDiceFace(_currentDiceValue),
                ),
              ),
            ),
          ),

          // Roll Instructions / Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _turn == LudoPlayer.red ? 'YOUR TURN TO ROLL' : 'VIP OPPONENT ROLLING...',
                style: TextStyle(
                  color: _turn == LudoPlayer.red ? CasinoColors.goldBright : Colors.white60,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Roll 6 for extra turn\n• Land on opponent to knock out',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const SizedBox(height: 6),
              if (_gameStarted && _turn == LudoPlayer.red)
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.casino, size: 16, color: Colors.black),
                    label: const Text('ROLL NOW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    onPressed: canRoll ? _rollDice : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CasinoColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiceFace(int value) {
    switch (value) {
      case 1:
        return _buildPipCircle();
      case 2:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_DicePip(), _DicePip()],
        );
      case 3:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Align(alignment: Alignment.topLeft, child: _DicePip()),
            Align(alignment: Alignment.center, child: _DicePip()),
            Align(alignment: Alignment.bottomRight, child: _DicePip()),
          ],
        );
      case 4:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip()]),
          ],
        );
      case 5:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip()]),
            _DicePip(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip()]),
          ],
        );
      case 6:
      default:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip(), _DicePip()]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_DicePip(), _DicePip(), _DicePip()]),
          ],
        );
    }
  }

  Widget _buildPipCircle() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Color(0xFFB71C1C), // Red royal pip
        shape: BoxShape.circle,
      ),
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
            // Quick Bet Selectors
            if (!_gameStarted) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [20, 50, 100, 250, 500].map((amt) {
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
            ],

            // Main Action Button (Start Duel or Roll)
            GoldenButton(
              label: !_gameStarted
                  ? 'START LUDO DUEL  (🪙 ${_betAmount.toInt()})'
                  : (_turn == LudoPlayer.red ? 'ROLL DICE 🎲' : 'OPPONENT ROLLING...'),
              height: 50,
              onPressed: !_gameStarted
                  ? _startGame
                  : (_turn == LudoPlayer.red && !_isRolling ? _rollDice : null),
            ),
          ],
        ),
      ),
    );
  }
}

class _DicePip extends StatelessWidget {
  const _DicePip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        shape: BoxShape.circle,
      ),
    );
  }
}
