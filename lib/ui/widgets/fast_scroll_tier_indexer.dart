import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

class FastScrollTierIndexer extends StatelessWidget {
  final int activeTier;
  final ValueChanged<int> onTierSelected;

  const FastScrollTierIndexer({
    super.key,
    required this.activeTier,
    required this.onTierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.slateCardElevated.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slateBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          for (int tier = 1; tier <= 6; tier++)
            Expanded(
              child: _buildTierButton(tier),
            ),
        ],
      ),
    );
  }

  Widget _buildTierButton(int tier) {
    final isSelected = tier == activeTier;

    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Rule 5: Opaque hit testing
      onTap: () => onTierSelected(tier),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.emeraldPrimary : Colors.transparent,
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : Border.all(color: AppColors.slateBorder, width: 0.8),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: AppColors.emeraldGlow,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              'T$tier',
              style: AppTheme.latin(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMediumContrast,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
