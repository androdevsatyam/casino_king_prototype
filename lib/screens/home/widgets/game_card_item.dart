import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../models/game_model.dart';
import '../../../core/constants/sound_effects.dart';

class GameCardItem extends StatelessWidget {
  final GameModel game;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const GameCardItem({
    super.key,
    required this.game,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CasinoAudioFeedback.buttonClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Game Thumbnail Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: game.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: game.isHot
                      ? const Color(0xFFFF5252).withValues(alpha: 0.8)
                      : CasinoColors.borderGold.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  children: [
                    // Background Art Pattern & Glowing Icon
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 0.25,
                        child: Icon(
                          game.icon,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Central 3D Visual Artwork
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.35),
                              border: Border.all(
                                color: CasinoColors.gold.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              game.icon,
                              size: 28,
                              color: CasinoColors.goldBright,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFFD49B28),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              game.provider,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top-Left Badges (HOT / NEW / 1000X)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Row(
                        children: [
                          if (game.isHot)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF3D00), Color(0xFFDD2C00)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.whatshot, size: 8, color: Colors.white),
                                  SizedBox(width: 1),
                                  Text(
                                    'HOT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (game.isNew) ...[
                            if (game.isHot) const SizedBox(width: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                          if (game.multiplierTag.isNotEmpty && !game.isHot && !game.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                game.multiplierTag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Top-Right Favorite Star
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          CasinoAudioFeedback.buttonClick();
                          onFavoriteTap();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            size: 13,
                            color: isFavorite ? CasinoColors.goldBright : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Game Title below card
          Text(
            game.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
