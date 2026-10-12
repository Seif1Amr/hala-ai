import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

class HeartsCounterWidget extends StatelessWidget {
  final int hearts;
  final VoidCallback onTap;

  const HeartsCounterWidget({
    super.key,
    required this.hearts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.slateCardElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hearts <= 3 ? AppColors.crimsonHeart : AppColors.slateBorder,
            width: 1,
          ),
          boxShadow: hearts <= 3
              ? [
                  const BoxShadow(
                    color: AppColors.crimsonGlow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.crimsonHeart,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              '$hearts',
              style: AppTheme.latin(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hearts <= 3 ? AppColors.crimsonHeart : AppColors.textHighContrast,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.add_circle_outline,
              color: AppColors.emeraldLight,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
