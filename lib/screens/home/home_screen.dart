import 'package:flutter/material.dart';
import '../../core/theme/casino_colors.dart';
import '../../core/widgets/floating_support_button.dart';
import '../../models/game_model.dart';
import '../../state/casino_state.dart';
import '../lucky_wheel/lucky_wheel_dialog.dart';
import '../games/aviator/aviator_game_screen.dart';
import '../games/slots/slots_game_screen.dart';
import '../games/roulette/roulette_game_screen.dart';
import 'widgets/casino_header.dart';
import 'widgets/live_ticker_bar.dart';
import 'widgets/hero_jackpot_banner.dart';
import 'widgets/filter_tabs_bar.dart';
import 'widgets/category_nav_rail.dart';
import 'widgets/game_grid_view.dart';
import 'widgets/provider_banners_view.dart';

class HomeScreen extends StatefulWidget {
  final CasinoState state;
  final VoidCallback onDepositTap;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onDepositTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _launchGame(GameModel game) {
    widget.state.markGamePlayed(game);

    Widget screen;
    if (game.id.contains('aviator') || game.id.contains('fly')) {
      screen = AviatorGameScreen(state: widget.state);
    } else if (game.id.contains('slot') || game.id.contains('gems') || game.id.contains('money')) {
      screen = SlotsGameScreen(state: widget.state);
    } else {
      screen = RouletteGameScreen(state: widget.state);
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => screen,
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    // Show large provider banners when "Casino" is clicked (matches Reference Images 1 & 2!)
    final bool showProviderBanners = state.activeCategory == 'Casino';

    return Scaffold(
      backgroundColor: CasinoColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Casino Top Header
                CasinoHeader(
                  state: state,
                  onDepositTap: widget.onDepositTap,
                ),

                // 2. Animated Winner Ticker Marquee (Matching ref images)
                LiveTickerBar(notices: state.winnerTicker),

                // 3. Daily Reward Carousel Hero Banner (Matching ref 3)
                HeroJackpotBanner(
                  onClaimTap: () => showLuckyWheelDialog(context, state),
                ),

                // 4. Filter Tabs Bar: [All Game] [Favorite] [Recent]
                FilterTabsBar(state: state),

                // 5. Main Content: Left Nav Rail + Right Game Grid / Provider Banners
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Vertical Category Rail (Hot, Casino, Slots, Crash, Fishing, Games, Sports)
                      CategoryNavRail(state: state),

                      // Right Content Area (Responsive Grid or Provider Banners)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: showProviderBanners
                              ? ProviderBannersView(
                                  key: const ValueKey('providers'),
                                  onGameSelected: _launchGame,
                                )
                              : GameGridView(
                                  key: ValueKey('grid_${state.activeCategory}_${state.activeFilter}'),
                                  state: state,
                                  onGameSelected: _launchGame,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 6. Floating 24/7 VIP Customer Support Button (Matching ref 1, 2, 3)
            const Positioned(
              right: 14,
              bottom: 14,
              child: FloatingSupportButton(),
            ),
          ],
        ),
      ),
    );
  }
}
