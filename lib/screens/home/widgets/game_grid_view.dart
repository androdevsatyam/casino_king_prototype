import 'package:flutter/material.dart';
import '../../../models/game_model.dart';
import '../../../state/casino_state.dart';
import 'game_card_item.dart';

class GameGridView extends StatelessWidget {
  final CasinoState state;
  final Function(GameModel game) onGameSelected;

  const GameGridView({
    super.key,
    required this.state,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    final games = state.filteredGames;

    if (games.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No games in this category yet.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic column calculation for phone screens (matching 3 columns in ref 3)
        final crossAxisCount = constraints.maxWidth > 340 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: games.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.78,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final game = games[index];
            final isFav = state.isFavorite(game.id);

            return GameCardItem(
              game: game,
              isFavorite: isFav,
              onFavoriteTap: () => state.toggleFavorite(game.id),
              onTap: () => onGameSelected(game),
            );
          },
        );
      },
    );
  }
}
