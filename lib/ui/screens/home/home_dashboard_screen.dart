import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/dialect_matrix.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dialect.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../providers/curriculum_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/active_recall_ad_dialog.dart';
import '../../widgets/dialect_selector_pill.dart';
import '../../widgets/hala_wide_hero_stage.dart';
import '../../widgets/hearts_counter_widget.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final conversation = context.watch<ConversationProvider>();
    final curriculum = context.watch<CurriculumProvider>();
    final wallet = context.watch<MonetizationProvider>();
    final appLang = appState.displayLanguage;
    final activeDialect = appState.activeDialect;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emeraldPrimary, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(AppStrings.get('appName', lang: appLang)),
          ],
        ),
        actions: [
          // Daily Streak Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.slateCardElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.amberWarm, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: AppColors.amberWarm, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${wallet.streakDays}d',
                  style: AppTheme.latin(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.amberLight),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Hearts counter
          HeartsCounterWidget(
            hearts: wallet.hearts,
            onTap: () => ActiveRecallAdDialog.show(context),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // RULE 2: Widescreen Hero Stage (Avatar at top)
              GestureDetector(
                onTap: () => onNavigateTab(1), // Jump to Conversation Salon
                behavior: HitTestBehavior.opaque,
                child: HalaWideHeroStage(
                  avatarState: conversation.avatarState,
                  dialect: activeDialect,
                  statusText: 'Tap to Chat with Hala',
                ),
              ),
              const SizedBox(height: 8),

              // Segmented Dialect Selector Pill placed UNDER the avatar
              DialectSelectorPill(
                activeDialect: activeDialect,
                onDialectChanged: (d) {
                  appState.setActiveDialect(d);
                  conversation.setDialect(d);
                  curriculum.loadLevels(d);
                },
              ),
              const SizedBox(height: 12),

              // Daily Streak Claim Card (if not claimed today)
              if (!wallet.hasDailyBonusClaimedToday)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.amberGoldGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, color: Colors.black, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Streak Reward Ready!',
                                style: AppTheme.latin(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                              ),
                              Text(
                                'Claim +10 Hearts to practice your speaking today.',
                                style: AppTheme.latin(fontSize: 12, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => wallet.claimDailyStreakBonus(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: const Text('Claim'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Curriculum Quick Progress Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.slateCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, color: AppColors.emeraldLight, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Curriculum Mastery',
                                style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            '${curriculum.completedCount} / 600 Levels',
                            style: AppTheme.latin(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.amberLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: curriculum.completedCount / 600.0,
                        backgroundColor: AppColors.midnightSand,
                        color: AppColors.emeraldPrimary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => onNavigateTab(2), // Jump to Curriculum
                          child: const Text('Continue to Curriculum (600 Levels)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tri-Dialect Matrix Spotlight
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tri-Dialect Matrix Spotlight',
                      style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => onNavigateTab(3), // Jump to Mastery Hub
                      child: Text(
                        'View All',
                        style: AppTheme.latin(fontSize: 13, color: AppColors.emeraldLight, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Horizontal Carousel of Matrix Items
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final item = DialectMatrix.items[index];
                    return _buildSpotlightCard(context, item, activeDialect);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Conversation Salon Launch CTA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGlowGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.emeraldDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.record_voice_over, color: AppColors.emeraldLight, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speak with Hala in ${activeDialect.englishName}',
                                  style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                                Text(
                                  'Powered by client-side Gemini 2.0 Flash engine',
                                  style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => onNavigateTab(1),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat with Hala'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSpotlightCard(BuildContext context, DialectMatrixItem item, DialectType dialect) {
    final tts = context.watch<ArabicTtsService>();
    final targetPhrase = item.getPhraseFor(dialect);
    final targetPhonetic = item.getPhoneticFor(dialect);
    final isLoading = tts.isTextLoading(targetPhrase);
    final isSpeaking = tts.isTextSpeaking(targetPhrase);

    Color borderColor = AppColors.slateBorder;
    List<BoxShadow> shadows = [];
    if (isLoading) {
      borderColor = AppColors.amberWarm;
      shadows = [
        BoxShadow(
          color: AppColors.amberWarm.withValues(alpha: 0.35),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (isSpeaking) {
      borderColor = AppColors.emeraldPrimary;
      shadows = [
        BoxShadow(
          color: AppColors.emeraldPrimary.withValues(alpha: 0.45),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    }

    return GestureDetector(
      onTap: () => tts.speak(targetPhrase, dialect: dialect),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.slateCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: (isLoading || isSpeaking) ? 1.5 : 1),
          boxShadow: shadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.conceptEn,
                    style: AppTheme.latin(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.amberWarm),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberWarm),
                    ),
                  )
                else if (isSpeaking)
                  const Icon(Icons.graphic_eq, size: 18, color: AppColors.emeraldLight)
                else
                  const Icon(Icons.volume_up, size: 18, color: AppColors.emeraldLight),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                targetPhrase,
                style: AppTheme.arabic(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                targetPhonetic,
                style: AppTheme.phonetic(fontSize: 12, color: AppColors.textMediumContrast),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dialect.pillLabel,
                  style: AppTheme.latin(fontSize: 11, color: AppColors.emeraldLight, fontWeight: FontWeight.w600),
                ),
                if (isLoading)
                  Text(
                    'Generating speech...',
                    style: AppTheme.latin(fontSize: 10, color: AppColors.amberWarm, fontWeight: FontWeight.w600),
                  )
                else if (isSpeaking)
                  Text(
                    'Playing audio...',
                    style: AppTheme.latin(fontSize: 10, color: AppColors.emeraldLight, fontWeight: FontWeight.w600),
                  )
                else
                  Text(
                    'Tap to hear',
                    style: AppTheme.latin(fontSize: 10, color: AppColors.textMuted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
