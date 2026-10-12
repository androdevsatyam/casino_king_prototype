import 'package:flutter/material.dart';
import '../../../core/theme/casino_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../state/casino_state.dart';

class FilterTabsBar extends StatelessWidget {
  final CasinoState state;

  const FilterTabsBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: AppConstants.filters.map((filter) {
          final isSelected = state.activeFilter == filter;

          IconData icon;
          if (filter == AppConstants.filterAll) {
            icon = Icons.style_outlined;
          } else if (filter == AppConstants.filterFavorite) {
            icon = Icons.favorite;
          } else {
            icon = Icons.history_rounded;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => state.selectFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF263B66), Color(0xFF132242)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isSelected ? null : CasinoColors.bgDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? CasinoColors.gold : CasinoColors.borderMuted,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: CasinoColors.gold.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected ? CasinoColors.goldBright : CasinoColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : CasinoColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
