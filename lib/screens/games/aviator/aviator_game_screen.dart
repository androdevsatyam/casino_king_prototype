import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/sound_effects.dart';
import '../../../core/widgets/animated_coin_counter.dart';
import '../../../core/widgets/coin_burst_overlay.dart';
import '../../../state/casino_state.dart';

enum AviatorState { betting, flying, crashed }

class AviatorGameScreen extends StatefulWidget {
  final CasinoState state;

  const AviatorGameScreen({super.key, required this.state});

  @override
  State<AviatorGameScreen> createState() => _AviatorGameScreenState();
}

class _AviatorGameScreenState extends State<AviatorGameScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<CoinBurstOverlayState> _burstKey = GlobalKey<CoinBurstOverlayState>();

  AviatorState _gameState = AviatorState.betting;
  double _currentMultiplier = 1.00;
  double _crashPoint = 2.50;
  double _betAmount = 50.0;
  bool _hasActiveBet = false;
  bool _cashedOut = false;
  double _wonAmount = 0.0;
  int _bettingCountdown = 5;

  Timer? _countdownTimer;
  Timer? _flightTimer;
  final Random _random = Random();

  final List<double> _history = [1.82, 3.45, 1.15, 14.80, 2.10, 1.45, 6.22, 1.05, 4.19];
  final List<Map<String, dynamic>> _liveBets = [];

  @override
  void initState() {
    super.initState();
    _startBettingPhase();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flightTimer?.cancel();
    super.dispose();
  }

  void _startBettingPhase() {
    setState(() {
      _gameState = AviatorState.betting;
      _currentMultiplier = 1.00;
      _cashedOut = false;
      _wonAmount = 0.0;
      _bettingCountdown = 5;
      _generateSimulatedLiveBets();
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_bettingCountdown > 1) {
          _bettingCountdown--;
        } else {
          _countdownTimer?.cancel();
          _startFlight();
        }
      });
    });
  }

  void _generateSimulatedLiveBets() {
    _liveBets.clear();
    final names = ['Tiger_99', 'Alex_Pro', 'VipRider', 'QueenAce', 'JackpotKid', 'LuckyBull'];
    final chips = [20, 50, 100, 250, 500, 1000];
    for (var name in names) {
      _liveBets.add({
        'user': name,
        'bet': chips[_random.nextInt(chips.length)].toDouble(),
        'cashedOut': false,
        'cashOutMult': 0.0,
      });
    }
  }

  void _startFlight() {
    // Determine crash point with ~97% RTP logic
    final r = _random.nextDouble();
    if (r < 0.08) {
      _crashPoint = 1.00 + (_random.nextDouble() * 0.15); // Instant crash
    } else if (r < 0.65) {
      _crashPoint = 1.20 + (_random.nextDouble() * 2.2); // Low-mid crash (1.20x - 3.40x)
    } else if (r < 0.92) {
      _crashPoint = 3.00 + (_random.nextDouble() * 7.0); // High crash (3x - 10x)
    } else {
      _crashPoint = 10.0 + (_random.nextDouble() * 40.0); // Mega flight!
    }

    setState(() {
      _gameState = AviatorState.flying;
      _currentMultiplier = 1.00;
    });

    final startTime = DateTime.now();
    _flightTimer?.cancel();
    _flightTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      // Exponential curve: 1.0 * e^(0.16 * t)
      final newMult = pow(e, 0.17 * elapsed).toDouble();

      // Check simulated bets cash out
      for (var b in _liveBets) {
        if (!b['cashedOut'] && newMult > (1.2 + _random.nextDouble() * 2.5)) {
          b['cashedOut'] = true;
          b['cashOutMult'] = newMult;
        }
      }

      if (newMult >= _crashPoint) {
        _flightTimer?.cancel();
        _crashFlight();
      } else {
        setState(() {
          _currentMultiplier = newMult;
        });
      }
    });
  }

  void _crashFlight() {
    CasinoAudioFeedback.crashLoss();
    setState(() {
      _gameState = AviatorState.crashed;
      _history.insert(0, double.parse(_crashPoint.toStringAsFixed(2)));
      if (_history.length > 12) _history.removeLast();

      if (_hasActiveBet && !_cashedOut) {
        // Player lost their bet
        widget.state.settleBet(
          gameTitle: 'Aviator Pro',
          betAmount: _betAmount,
          winAmount: 0,
          multiplier: _crashPoint,
        );
        _hasActiveBet = false;
      }
    });

    // Auto restart next round after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startBettingPhase();
    });
  }

  void _placeBet() {
    if (widget.state.coinBalance < _betAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins! Please recharge in store.'),
          backgroundColor: CasinoColors.hotRed,
        ),
      );
      return;
    }

    final success = widget.state.placeBet(_betAmount);
    if (success) {
      setState(() {
        _hasActiveBet = true;
      });
      CasinoAudioFeedback.chipBet();
    }
  }

  void _cashOut() {
    if (!_hasActiveBet || _cashedOut || _gameState != AviatorState.flying) return;

    final winTotal = _betAmount * _currentMultiplier;
    setState(() {
      _cashedOut = true;
      _wonAmount = winTotal;
      _hasActiveBet = false;
    });

    widget.state.settleBet(
      gameTitle: 'Aviator Pro',
      betAmount: _betAmount,
      winAmount: winTotal,
      multiplier: _currentMultiplier,
    );

    // Trigger golden coin shower!
    _burstKey.currentState?.triggerBurst(
      title: 'CASHED OUT ${_currentMultiplier.toStringAsFixed(2)}X!',
      amount: winTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CoinBurstOverlay(
      overlayKey: _burstKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0207),
        appBar: AppBar(
          backgroundColor: const Color(0xFF160309),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flight_takeoff, color: Color(0xFFFF2A42)),
              const SizedBox(width: 8),
              const Text(
                'AVIATOR PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2A42),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CRASH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
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
            // Multiplier History Ribbon (Top)
            _buildHistoryRibbon(),

            // Main Canvas Flight Arena
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AviatorFlightPainter(
                        gameState: _gameState,
                        multiplier: _currentMultiplier,
                      ),
                    ),
                  ),

                  // Center State Overlay (Multiplier / Flew Away / Countdown)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_gameState == AviatorState.betting) ...[
                          Text(
                            'NEXT ROUND IN',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CasinoColors.gold,
                                width: 3,
                              ),
                              boxShadow: CasinoColors.goldGlow,
                            ),
                            child: Center(
                              child: Text(
                                '$_bettingCountdown',
                                style: const TextStyle(
                                  color: CasinoColors.goldBright,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ] else if (_gameState == AviatorState.crashed) ...[
                          const Text(
                            'FLEW AWAY!',
                            style: TextStyle(
                              color: Color(0xFFFF2A42),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(color: Colors.red, blurRadius: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_crashPoint.toStringAsFixed(2)}x',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${_currentMultiplier.toStringAsFixed(2)}x',
                            style: TextStyle(
                              color: _cashedOut ? CasinoColors.winGreen : Colors.white,
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              shadows: [
                                Shadow(
                                  color: _cashedOut
                                      ? CasinoColors.winGreen
                                      : const Color(0xFFFF2A42).withValues(alpha: 0.8),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          if (_cashedOut)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: CasinoColors.winGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'WON +${_wonAmount.toStringAsFixed(0)} COINS',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  // Floating Jet Aircraft
                  if (_gameState == AviatorState.flying)
                    Positioned(
                      left: _calculateJetX(context),
                      bottom: _calculateJetY(context),
                      child: const _AviatorJetWidget(),
                    ),
                ],
              ),
            ),

            // Live Players Mini-Ticker & Bet Area
            _buildLiveBetsPreview(),

            // Betting Control Console
            _buildBettingConsole(),
          ],
        ),
      ),
    );
  }

  double _calculateJetX(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 90;
    final progress = ((_currentMultiplier - 1.0) / 4.0).clamp(0.05, 0.88);
    return width * progress;
  }

  double _calculateJetY(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.35;
    final progress = ((_currentMultiplier - 1.0) / 4.0).clamp(0.1, 0.85);
    return height * progress;
  }

  Widget _buildHistoryRibbon() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF140208),
        border: Border(bottom: BorderSide(color: Color(0x33FF2A42))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _history.length,
        itemBuilder: (context, idx) {
          final mult = _history[idx];
          final isHigh = mult >= 2.0;
          final isMega = mult >= 10.0;

          Color badgeColor = const Color(0xFF2A1119);
          Color textColor = Colors.white70;

          if (isMega) {
            badgeColor = const Color(0xFF7C3AED);
            textColor = Colors.white;
          } else if (isHigh) {
            badgeColor = const Color(0xFF047857);
            textColor = const Color(0xFF6EE7B7);
          }

          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isMega ? CasinoColors.gold : Colors.white10,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${mult.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveBetsPreview() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF120309),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _liveBets.length,
        itemBuilder: (context, idx) {
          final bet = _liveBets[idx];
          final bool cashed = bet['cashedOut'];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cashed ? const Color(0xFF064E3B) : Colors.black45,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: cashed ? CasinoColors.winGreen : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${bet['user']}: 🪙${(bet['bet'] as double).toInt()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                if (cashed) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${(bet['cashOutMult'] as double).toStringAsFixed(2)}x',
                    style: const TextStyle(
                      color: CasinoColors.winGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBettingConsole() {
    final bool canCashOut = _gameState == AviatorState.flying && _hasActiveBet && !_cashedOut;
    final double winPreview = _betAmount * _currentMultiplier;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF1A040B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0xFFFF2A42), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Quick Chip Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [10, 50, 100, 250, 500, 1000].map((amt) {
                final isSelected = _betAmount == amt.toDouble();
                return GestureDetector(
                  onTap: () {
                    CasinoAudioFeedback.chipBet();
                    setState(() => _betAmount = amt.toDouble());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? CasinoColors.gold : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                      ),
                    ),
                    child: Text(
                      '$amt',
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Stepper and Primary Button
            Row(
              children: [
                // Decrement & Increment Stepper
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                        onPressed: () {
                          if (_betAmount > 10) {
                            CasinoAudioFeedback.chipBet();
                            setState(() => _betAmount = (_betAmount - 10).clamp(10, 50000));
                          }
                        },
                      ),
                      Text(
                        '🪙 ${_betAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: CasinoColors.goldBright,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        onPressed: () {
                          CasinoAudioFeedback.chipBet();
                          setState(() => _betAmount = (_betAmount + 10).clamp(10, 50000));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Main Action Button (BET or CASH OUT)
                Expanded(
                  child: GestureDetector(
                    onTap: canCashOut
                        ? _cashOut
                        : (!_hasActiveBet ? _placeBet : null),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: canCashOut
                            ? const LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFF00A34C)],
                              )
                            : (_hasActiveBet
                                ? const LinearGradient(
                                    colors: [Color(0xFF374151), Color(0xFF1F2937)],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFFFF2A42), Color(0xFFB7091B)],
                                  )),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: canCashOut ? CasinoColors.winGreen : Colors.white24,
                          width: 1.5,
                        ),
                        boxShadow: canCashOut
                            ? [
                                BoxShadow(
                                  color: CasinoColors.winGreen.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              canCashOut
                                  ? 'CASH OUT'
                                  : (_hasActiveBet ? 'BET WAITING...' : 'BET'),
                              style: TextStyle(
                                color: canCashOut ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (canCashOut)
                              Text(
                                '₹${winPreview.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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

class _AviatorJetWidget extends StatelessWidget {
  const _AviatorJetWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Jet flame exhaust glow
          Positioned(
            left: 2,
            bottom: 4,
            child: Container(
              width: 14,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9100),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFF3D00), blurRadius: 10, spreadRadius: 3),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.flight,
            color: Color(0xFFFF2A42),
            size: 38,
          ),
        ],
      ),
    );
  }
}

class _AviatorFlightPainter extends CustomPainter {
  final AviatorState gameState;
  final double multiplier;

  _AviatorFlightPainter({
    required this.gameState,
    required this.multiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double y = 40; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 40; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (gameState != AviatorState.flying) return;

    final progress = ((multiplier - 1.0) / 4.0).clamp(0.05, 0.88);
    final targetX = size.width * progress;
    final targetY = size.height - (size.height * 0.7 * progress);

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      targetX * 0.5,
      size.height,
      targetX,
      targetY,
    );

    // Glow under flight path
    final fillPath = Path.from(path)
      ..lineTo(targetX, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF2A42).withValues(alpha: 0.35),
          const Color(0xFFFF2A42).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, targetX, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Glowing Flight Line
    final linePaint = Paint()
      ..color = const Color(0xFFFF2A42)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AviatorFlightPainter oldDelegate) {
    return oldDelegate.multiplier != multiplier || oldDelegate.gameState != gameState;
  }
}
