import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../models/game_model.dart';
import '../../../core/constants/sound_effects.dart';

class ProviderBannersView extends StatelessWidget {
  final Function(GameModel game) onGameSelected;

  const ProviderBannersView({
    super.key,
    required this.onGameSelected,
  });

  static const List<Map<String, dynamic>> _providers = [
    {
      'name': 'Evolution',
      'tagline': 'A realistic and immersive experience',
      'tag': 'TOP LIVE',
      'color': Color(0xFF1E3A8A),
      'icon': Icons.casino,
      'gameId': 'evolution_casino',
    },
    {
      'name': 'Sexy Baccarat',
      'tagline': 'Sexy dealer dealing cards online',
      'tag': 'HOT DEALER',
      'color': Color(0xFF831843),
      'icon': Icons.style,
      'gameId': 'dragon_tiger',
    },
    {
      'name': 'Playtech',
      'tagline': 'Game Creators Game Changers',
      'tag': 'PREMIER',
      'color': Color(0xFF4C1D95),
      'icon': Icons.stars,
      'gameId': 'royal_roulette',
    },
    {
      'name': 'JILI',
      'tagline': 'Your all-time favorite slot game',
      'tag': '1000X JACKPOT',
      'color': Color(0xFFB45309),
      'icon': Icons.diamond,
      'gameId': 'fortune_gems_500',
    },
    {
      'name': 'PG Soft',
      'tagline': 'The most efficient & stable game',
      'tag': 'POPULAR',
      'color': Color(0xFF065F46),
      'icon': Icons.filter_7,
      'gameId': 'fortune_777_slots',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _providers.length,
      itemBuilder: (context, index) {
        final p = _providers[index];

        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (p['color'] as Color).withValues(alpha: 0.9),
                CasinoColors.bgDark,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CasinoColors.borderGold.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                CasinoAudioFeedback.buttonClick();
                final game = GameModel.initialGames.firstWhere(
                  (g) => g.id == p['gameId'],
                  orElse: () => GameModel.initialGames.first,
                );
                onGameSelected(game);
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Provider Icon / Art
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                        border: Border.all(color: CasinoColors.gold, width: 1.5),
                        boxShadow: CasinoColors.goldGlow,
                      ),
                      child: Center(
                        child: Icon(
                          p['icon'] as IconData,
                          size: 26,
                          color: CasinoColors.goldBright,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                p['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: CasinoColors.gold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p['tag'] as String,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['tagline'] as String,
                            style: const TextStyle(
                              color: CasinoColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Play Button Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: CasinoColors.goldButtonGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
