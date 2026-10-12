import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/widgets/golden_button.dart';

class HeroJackpotBanner extends StatefulWidget {
  final VoidCallback onClaimTap;

  const HeroJackpotBanner({
    super.key,
    required this.onClaimTap,
  });

  @override
  State<HeroJackpotBanner> createState() => _HeroJackpotBannerState();
}

class _HeroJackpotBannerState extends State<HeroJackpotBanner> {
  late PageController _pageController;
  int _activePage = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, dynamic>> _slides = [
    {
      'badge': 'DAILY REWARD UP TO',
      'amount': '₹1,000,000+',
      'subtitle': 'PLAY & WIN JACKPOT FOR FREE',
      'buttonText': 'SPIN & WIN',
      'bgGradient': [Color(0xFF0F265C), Color(0xFF1E3A8A), Color(0xFF0F172A)],
      'icon': Icons.emoji_events,
    },
    {
      'badge': 'FIRST RECHARGE BONUS',
      'amount': '+100% EXTRA',
      'subtitle': 'DOUBLE YOUR COINS INSTANTLY',
      'buttonText': 'CLAIM NOW',
      'bgGradient': [Color(0xFF4C0519), Color(0xFF881337), Color(0xFF1E0209)],
      'icon': Icons.stars,
    },
    {
      'badge': 'VIP HIGH ROLLER CLUB',
      'amount': '₹50,000 WEEKLY',
      'subtitle': 'EXCLUSIVE CASHBACK & GIFTS',
      'buttonText': 'JOIN VIP',
      'bgGradient': [Color(0xFF3B0764), Color(0xFF581C87), Color(0xFF1E0533)],
      'icon': Icons.workspace_premium,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _activePage = (_activePage + 1) % _slides.length;
        _pageController.animateToPage(
          _activePage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 162,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _activePage = idx),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: slide['bgGradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CasinoColors.gold.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background Glowing Ambient Circles & Coins Illustration
                    Positioned(
                      right: -10,
                      bottom: -15,
                      child: Opacity(
                        opacity: 0.25,
                        child: Icon(
                          slide['icon'] as IconData,
                          size: 130,
                          color: CasinoColors.gold,
                        ),
                      ),
                    ),

                    // Main Content
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Tag Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: CasinoColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: CasinoColors.gold,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  slide['badge'] as String,
                                  style: const TextStyle(
                                    color: CasinoColors.goldBright,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Amount with 3D Gold Gradient Look
                              Text(
                                slide['amount'] as String,
                                style: const TextStyle(
                                  color: CasinoColors.goldBright,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFD49B28),
                                      blurRadius: 10,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),

                              // Subtitle
                              Text(
                                slide['subtitle'] as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Action Button
                              GoldenButton(
                                label: slide['buttonText'] as String,
                                height: 30,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                                onPressed: widget.onClaimTap,
                              ),
                            ],
                          ),
                        ),

                        // Right 3D Trophy / Treasure Graphics
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                CasinoColors.gold.withValues(alpha: 0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              slide['icon'] as IconData,
                              size: 58,
                              color: CasinoColors.goldBright,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFFB87B00),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Pagination Dots (Matching Reference Image 3)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final bool isActive = i == _activePage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? CasinoColors.gold : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
