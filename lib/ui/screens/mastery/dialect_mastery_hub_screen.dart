import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dialect.dart';
import '../../../data/repositories/mastery_repository.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/active_recall_ad_dialog.dart';
import '../../widgets/dialect_selector_pill.dart';
import '../../widgets/hearts_counter_widget.dart';

class DialectMasteryHubScreen extends StatefulWidget {
  const DialectMasteryHubScreen({super.key});

  @override
  State<DialectMasteryHubScreen> createState() => _DialectMasteryHubScreenState();
}

class _DialectMasteryHubScreenState extends State<DialectMasteryHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _speakPhrase(String phrase, DialectType dialect) {
    final tts = context.read<ArabicTtsService>();
    tts.speak(phrase, dialect: dialect);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final wallet = context.watch<MonetizationProvider>();
    final appLang = appState.displayLanguage;
    final activeDialect = appState.activeDialect;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Text(AppStrings.get('navMastery', lang: appLang)),
        actions: [
          HeartsCounterWidget(
            hearts: wallet.hearts,
            onTap: () => ActiveRecallAdDialog.show(context),
          ),
          const SizedBox(width: 14),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.emeraldPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.emeraldLight,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTheme.latin(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Conjugations', icon: Icon(Icons.sync_alt, size: 18)),
            Tab(text: 'Question Words', icon: Icon(Icons.help_outline, size: 18)),
            Tab(text: 'Negation Systems', icon: Icon(Icons.block, size: 18)),
            Tab(text: 'Gulf Honorifics', icon: Icon(Icons.handshake_outlined, size: 18)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                DialectSelectorPill(
                  activeDialect: activeDialect,
                  onDialectChanged: (d) => appState.setActiveDialect(d),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildConjugationsTab(),
                      _buildQuestionWordsTab(),
                      _buildNegationsTab(),
                      _buildHonorificsTab(),
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

  // --- TAB 1: CONJUGATIONS ---
  Widget _buildConjugationsTab() {
    const list = MasteryRepository.conjugations;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.pronounEn,
                    style: AppTheme.latin(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
                  ),
                  Text(
                    item.standardAr,
                    style: AppTheme.arabic(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Divider(color: AppColors.slateDivider, height: 20),

              // Tri-Dialect Matrix Rows
              _buildDialectRow('🇪🇬 Egyptian', item.egyptian, DialectType.egyptian),
              const SizedBox(height: 8),
              _buildDialectRow('🇸🇦 Saudi', item.saudi, DialectType.saudi),
              const SizedBox(height: 8),
              _buildDialectRow('🇦🇪 Emirati', item.emirati, DialectType.emirati),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.midnightSand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.note,
                  style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: QUESTION WORDS ---
  Widget _buildQuestionWordsTab() {
    const list = MasteryRepository.questionWords;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.english,
                    style: AppTheme.latin(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.amberWarm),
                  ),
                  Text(
                    'Standard: ${item.standard}',
                    style: AppTheme.arabic(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Divider(color: AppColors.slateDivider, height: 20),

              Row(
                children: [
                  Expanded(child: _buildMiniDialectChip('🇪🇬 Egyptian', item.egyptian, DialectType.egyptian)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildMiniDialectChip('🇸🇦 Saudi', item.saudi, DialectType.saudi)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildMiniDialectChip('🇦🇪 Emirati', item.emirati, DialectType.emirati)),
                ],
              ),
              const SizedBox(height: 12),

              // Example Sentence
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.midnightSand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    'مثال: ${item.exampleSentence}',
                    style: AppTheme.arabic(fontSize: 14, color: AppColors.emeraldLight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: NEGATION SYSTEMS ---
  Widget _buildNegationsTab() {
    const list = MasteryRepository.negations;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.conceptEn,
                style: AppTheme.latin(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                item.ruleExplanation,
                style: AppTheme.latin(fontSize: 12, color: AppColors.amberLight),
              ),
              const Divider(color: AppColors.slateDivider, height: 20),

              _buildDialectRow('🇪🇬 Egyptian', item.egyptianExample, DialectType.egyptian),
              const SizedBox(height: 8),
              _buildDialectRow('🇸🇦 Saudi', item.saudiExample, DialectType.saudi),
              const SizedBox(height: 8),
              _buildDialectRow('🇦🇪 Emirati', item.emiratiExample, DialectType.emirati),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 4: GULF HONORIFICS ---
  Widget _buildHonorificsTab() {
    const list = MasteryRepository.honorifics;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      item.phrase,
                      style: AppTheme.arabic(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.amberWarm),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppColors.emeraldLight, size: 20),
                    onPressed: () => _speakPhrase(item.phrase, item.primaryDialect),
                  ),
                ],
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  item.phonetic,
                  style: AppTheme.phonetic(fontSize: 13, color: AppColors.textMediumContrast),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Literal: "${item.literalMeaning}"',
                style: AppTheme.latin(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.midnightSand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.culturalUse,
                  style: AppTheme.latin(fontSize: 12, color: AppColors.textHighContrast),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialectRow(String label, String phrase, DialectType dialect) {
    final tts = context.watch<ArabicTtsService>();
    final isLoading = tts.isTextLoading(phrase);
    final isSpeaking = tts.isTextSpeaking(phrase);

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTheme.latin(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              phrase,
              style: AppTheme.arabic(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberWarm),
              ),
            ),
          )
        else if (isSpeaking)
          IconButton(
            icon: const Icon(Icons.graphic_eq, size: 16, color: AppColors.emeraldLight),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _speakPhrase(phrase, dialect),
          )
        else
          IconButton(
            icon: const Icon(Icons.volume_up, size: 16, color: AppColors.emeraldLight),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _speakPhrase(phrase, dialect),
          ),
      ],
    );
  }

  Widget _buildMiniDialectChip(String label, String phrase, DialectType dialect) {
    final tts = context.watch<ArabicTtsService>();
    final isLoading = tts.isTextLoading(phrase);
    final isSpeaking = tts.isTextSpeaking(phrase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.midnightSand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        children: [
          Text(label, style: AppTheme.latin(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              style: AppTheme.arabic(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _speakPhrase(phrase, dialect),
            child: isLoading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberWarm),
                    ),
                  )
                : Icon(
                    isSpeaking ? Icons.graphic_eq : Icons.volume_up,
                    size: 14,
                    color: isSpeaking ? AppColors.emeraldPrimary : AppColors.emeraldLight,
                  ),
          ),
        ],
      ),
    );
  }
}
