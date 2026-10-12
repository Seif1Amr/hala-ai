import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dialect.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/hala_wide_hero_stage.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  late ConfettiController _confettiController;
  int _currentPage = 0;

  // Selected onboarding options
  DialectType _selectedDialect = DialectType.saudi;
  String _selectedGoal = 'Daily Social Fluency ☕';
  String _selectedProficiency = 'Novice (Introductory greetings)';
  bool _heartsClaimed = false;

  final List<String> _goals = [
    'Daily Social Fluency ☕',
    'Career & Business in the Gulf 💼',
    'Relocating & Living Abroad ✈️',
    'Cinema & Pop Culture (Egyptian) 🎬',
    'Hajj & Cultural Heritage 🕌',
  ];

  final List<Map<String, String>> _proficiencyLevels = [
    {
      'title': 'Novice (Introductory greetings)',
      'subtitle': 'Zero prior Arabic knowledge. Starting with warm greetings and basic manners.',
    },
    {
      'title': 'Elementary (Everyday basics & Souk)',
      'subtitle': 'Can order coffee and count. Want to navigate taxis, shops, and menus.',
    },
    {
      'title': 'Intermediate (Conversations & Travel)',
      'subtitle': 'Can hold simple chats. Want to master native dialect idioms and flow.',
    },
    {
      'title': 'Advanced (Business & Cultural humor)',
      'subtitle': 'Fluent in MSA or another dialect. Mastering nuanced Gulf idioms and jokes.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _playWelcomeAudio() async {
    final tts = context.read<ArabicTtsService>();
    final welcomeText = _selectedDialect.audioWelcomePhrase;
    await tts.speak(welcomeText, dialect: _selectedDialect);
  }

  Future<void> _claimHearts() async {
    final wallet = context.read<MonetizationProvider>();
    await wallet.grantStarterHearts();
    _confettiController.play();
    setState(() => _heartsClaimed = true);
  }

  Future<void> _finishOnboarding() async {
    final appState = context.read<AppStateProvider>();
    final conversation = context.read<ConversationProvider>();

    await appState.completeOnboarding(
      dialect: _selectedDialect,
      goal: _selectedGoal,
      proficiency: _selectedProficiency,
    );

    conversation.setDialect(_selectedDialect);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    _buildTopProgress(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        children: [
                          _buildSlide1Motivation(),
                          _buildSlide2Proficiency(),
                          _buildSlide3AudioWelcome(),
                        ],
                      ),
                    ),
                    _buildBottomControls(),
                  ],
                ),
              ),
            ),

            // Confetti Cannon
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppColors.emeraldPrimary,
                AppColors.amberWarm,
                Colors.white,
                Color(0xFFA855F7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i <= _currentPage
                      ? AppColors.emeraldPrimary
                      : AppColors.slateBorder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- SLIDE 1: MOTIVATION & DIALECT FOCUS ---
  Widget _buildSlide1Motivation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hala AI Learning Arabic',
            style: AppTheme.latin(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
          ),
          const SizedBox(height: 6),
          Text(
            'Why do you want to speak Arabic with Hala?',
            style: AppTheme.latin(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 14),

          // Primary Dialect Preference Selector
          Text(
            'Choose your primary dialect focus:',
            style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: DialectType.values.map((dialect) {
              final isSel = dialect == _selectedDialect;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDialect = dialect),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.emeraldDark : AppColors.slateCardElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? AppColors.emeraldPrimary : AppColors.slateBorder,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(dialect.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          dialect.shortArabicName,
                          style: AppTheme.arabic(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dialect.englishName.split(' ').first,
                          style: AppTheme.latin(fontSize: 11, color: AppColors.textMediumContrast),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Goals list
          Text(
            'Select your learning motivation:',
            style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._goals.map((goal) {
            final isSel = goal == _selectedGoal;
            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.slateCardElevated : AppColors.slateCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel ? AppColors.emeraldPrimary : AppColors.slateBorder,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSel ? Icons.check_circle : Icons.circle_outlined,
                      color: isSel ? AppColors.emeraldPrimary : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal,
                        style: AppTheme.latin(
                          fontSize: 15,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textHighContrast,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- SLIDE 2: PROFICIENCY BENCHMARK ---
  Widget _buildSlide2Proficiency() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proficiency Benchmark',
            style: AppTheme.latin(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
          ),
          const SizedBox(height: 6),
          Text(
            'What is your current speaking level?',
            style: AppTheme.latin(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Hala calibrates her speech rate and vocabulary to match you comfortably.',
            style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast),
          ),
          const SizedBox(height: 18),
          ..._proficiencyLevels.map((lvl) {
            final title = lvl['title']!;
            final subtitle = lvl['subtitle']!;
            final isSel = title == _selectedProficiency;

            return GestureDetector(
              onTap: () => setState(() => _selectedProficiency = title),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.slateCardElevated : AppColors.slateCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? AppColors.emeraldPrimary : AppColors.slateBorder,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSel ? Icons.check_circle : Icons.circle_outlined,
                      color: isSel ? AppColors.emeraldPrimary : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.latin(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSel ? Colors.white : AppColors.textHighContrast,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTheme.latin(
                              fontSize: 12,
                              color: AppColors.textMediumContrast,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- SLIDE 3: AUDIO WELCOME & STARTER HEARTS ---
  Widget _buildSlide3AudioWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Widescreen Stage Preview
          HalaWideHeroStage(
            avatarState: HalaAvatarState.speaking,
            dialect: _selectedDialect,
            statusText: 'Online • Hala AI Coach',
          ),
          const SizedBox(height: 18),

          Text(
            'Meet Hala, Your Speaking Coach',
            style: AppTheme.latin(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Listen to her welcoming greeting in ${_selectedDialect.englishName}:',
            textAlign: TextAlign.center,
            style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast),
          ),
          const SizedBox(height: 14),

          // Greeting Card with Audio Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.midnightSand,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    _selectedDialect.audioWelcomePhrase,
                    textAlign: TextAlign.center,
                    style: AppTheme.arabic(fontSize: 17, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _playWelcomeAudio,
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: const Text('Play Voice Greeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slateCardElevated,
                    foregroundColor: AppColors.emeraldLight,
                    side: const BorderSide(color: AppColors.emeraldPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Starter Hearts Gift Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.cardGlowGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _heartsClaimed ? AppColors.emeraldPrimary : AppColors.amberWarm,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.crimsonGlow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.crimsonHeart),
                  ),
                  child: const Icon(Icons.favorite, color: AppColors.crimsonHeart, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+15 Free Starter Hearts',
                        style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _heartsClaimed
                            ? 'Claimed! Ready to speak & learn.'
                            : 'Granted to jumpstart your conversations.',
                        style: AppTheme.latin(fontSize: 12, color: AppColors.amberLight),
                      ),
                    ],
                  ),
                ),
                if (!_heartsClaimed)
                  ElevatedButton(
                    onPressed: _claimHearts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amberWarm,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Claim'),
                  )
                else
                  const Icon(Icons.check_circle, color: AppColors.emeraldPrimary, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emeraldPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _currentPage < 2 ? 'Continue' : 'Start Speaking Arabic',
            style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
