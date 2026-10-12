import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dialect.dart';

class DialectSelectorPill extends StatelessWidget {
  final DialectType activeDialect;
  final ValueChanged<DialectType> onDialectChanged;

  const DialectSelectorPill({
    super.key,
    required this.activeDialect,
    required this.onDialectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slateCardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateBorder, width: 1),
      ),
      child: Row(
        children: DialectType.values.map((dialect) {
          final isSelected = dialect == activeDialect;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDialectChanged(dialect),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.emeraldDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.emeraldPrimary, width: 1.2)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dialect.flag,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dialect.shortArabicName,
                        style: AppTheme.arabic(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textMediumContrast,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
