import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/curriculum_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/active_recall_ad_dialog.dart';
import '../../widgets/dialect_selector_pill.dart';
import '../../widgets/fast_scroll_tier_indexer.dart';
import '../../widgets/hearts_counter_widget.dart';
import 'lesson_detail_screen.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final ScrollController _scrollController = ScrollController();

  final Map<int, String> _tierNames = {
    1: 'Tier 1: Foundations (Levels 1–100)',
    2: 'Tier 2: Everyday Life (Levels 101–200)',
    3: 'Tier 3: Social & Family (Levels 201–300)',
    4: 'Tier 4: Work & Professional (Levels 301–400)',
    5: 'Tier 5: Nuances & Idioms (Levels 401–500)',
    6: 'Tier 6: Native Fluency (Levels 501–600)',
  };

  final Map<int, String> _tierSubtitles = {
    1: 'Greetings, hospitality, numbers, coffee etiquette',
    2: 'Taxis, souks, bargaining, food, directions',
    3: 'Majlis manners, congratulations, emotions',
    4: 'Gulf corporate culture, meetings, formal emails',
    5: 'Proverbs, metaphors, humor, dialect contrasts',
    6: 'Fast native dialogue flow, media, poetry',
  };

  void _onTierSelected(int tier) {
    final curriculum = context.read<CurriculumProvider>();
    curriculum.selectTier(tier);

    // Smoothly scroll to top of list
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleStartLevel(CurriculumLevel level) {
    final curriculum = context.read<CurriculumProvider>();
    final canStart = curriculum.startLevel(
      level,
      onOutOfHearts: () => ActiveRecallAdDialog.show(context),
    );

    if (canStart) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LessonDetailScreen(level: level),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = context.watch<CurriculumProvider>();
    final wallet = context.watch<MonetizationProvider>();
    final appState = context.watch<AppStateProvider>();
    final appLang = appState.displayLanguage;
    final activeDialect = appState.activeDialect;

    final activeTier = curriculum.selectedTier;
    final tierLevels = curriculum.getLevelsForTier(activeTier);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Text(AppStrings.get('navCurriculum', lang: appLang)),
        actions: [
          HeartsCounterWidget(
            hearts: wallet.hearts,
            onTap: () => ActiveRecallAdDialog.show(context),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              children: [
                // Top Dialect Selector Pill
                DialectSelectorPill(
              activeDialect: activeDialect,
              onDialectChanged: (d) {
                appState.setActiveDialect(d);
                curriculum.loadLevels(d);
              },
            ),

            // Tier Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGlowGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slateBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _tierNames[activeTier] ?? 'Tier $activeTier',
                            style: AppTheme.latin(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '600 Levels Total',
                            style: AppTheme.latin(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tierSubtitles[activeTier] ?? '',
                      style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                    ),
                  ],
                ),
              ),
            ),

            // RULE 5: Stack containing the Levels List and full-height Fast-Scroll Indexer
            Expanded(
              child: Stack(
                children: [
                  // 100 Levels in active tier
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 56, // Leave right space for sticky fast-scroll indexer
                      top: 8,
                      bottom: 24,
                    ),
                    itemCount: tierLevels.length,
                    itemBuilder: (context, index) {
                      final level = tierLevels[index];
                      return _buildLevelCard(level);
                    },
                  ),

                  // RULE 5 MANDATORY IMPLEMENTATION: FastScrollTierIndexer
                  Positioned(
                    right: 6,
                    top: 8,
                    bottom: 12,
                    child: FastScrollTierIndexer(
                      activeTier: activeTier,
                      onTierSelected: _onTierSelected,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildLevelCard(CurriculumLevel level) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: level.isCompleted ? AppColors.emeraldPrimary.withValues(alpha: 0.6) : AppColors.slateBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleStartLevel(level),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Level Number Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: level.isCompleted ? AppColors.emeraldDark : AppColors.slateCardElevated,
                    border: Border.all(
                      color: level.isCompleted ? AppColors.emeraldPrimary : AppColors.slateBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: level.isCompleted
                        ? const Icon(Icons.check, color: AppColors.emeraldLight, size: 22)
                        : Text(
                            '${level.levelNumber}',
                            style: AppTheme.latin(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title and Arabic Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: AppTheme.latin(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          level.titleAr,
                          style: AppTheme.arabic(
                            fontSize: 13,
                            color: AppColors.amberLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stars and Action Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: List.generate(3, (starIdx) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: starIdx < level.stars ? AppColors.amberWarm : AppColors.slateBorder,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
