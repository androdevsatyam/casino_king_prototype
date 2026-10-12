import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../state/casino_state.dart';

class CategoryNavRail extends StatelessWidget {
  final CasinoState state;

  const CategoryNavRail({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: CasinoColors.bgSidebar,
        border: Border(
          right: BorderSide(
            color: CasinoColors.borderGoldSubtle,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final cat = AppConstants.categories[index];
          final isSelected = state.activeCategory == cat;

          return _CategoryRailItem(
            category: cat,
            isSelected: isSelected,
            onTap: () => state.selectCategory(cat),
          );
        },
      ),
    );
  }
}

class _CategoryRailItem extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryRailItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (category) {
      case AppConstants.catHot:
        icon = Icons.local_fire_department_rounded;
        iconColor = const Color(0xFFFF5722);
        break;
      case AppConstants.catCasino:
        icon = Icons.casino_rounded;
        iconColor = const Color(0xFFFFC107);
        break;
      case AppConstants.catSlots:
        icon = Icons.filter_7_rounded;
        iconColor = const Color(0xFFE91E63);
        break;
      case AppConstants.catCrash:
        icon = Icons.rocket_launch_rounded;
        iconColor = const Color(0xFF00E5FF);
        break;
      case AppConstants.catFishing:
        icon = Icons.phishing_rounded;
        iconColor = const Color(0xFF29B6F6);
        break;
      case AppConstants.catGames:
        icon = Icons.sports_esports_rounded;
        iconColor = const Color(0xFFAB47BC);
        break;
      case AppConstants.catSports:
        icon = Icons.sports_cricket_rounded;
        iconColor = const Color(0xFF66BB6A);
        break;
      default:
        icon = Icons.sports_esports;
        iconColor = CasinoColors.gold;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2C3E6B), Color(0xFF16203D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? CasinoColors.gold : Colors.white10,
            width: isSelected ? 1.5 : 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CasinoColors.gold.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glowing container or 3D badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? (category == AppConstants.catHot ? const Color(0xFFFF9800) : const Color(0xFF1E293B))
                    : const Color(0xFF121B2F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFE082) : Colors.white12,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected && category == AppConstants.catHot
                      ? Colors.white
                      : iconColor,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Category Label
            Text(
              category,
              style: TextStyle(
                color: isSelected ? CasinoColors.goldBright : CasinoColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
