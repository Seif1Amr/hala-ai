import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_similarity.dart';
import '../../../core/utils/audio_focus_guard.dart';
import '../../../data/models/lesson_model.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/curriculum_provider.dart';

class LessonDetailScreen extends StatefulWidget {
  final CurriculumLevel level;

  const LessonDetailScreen({super.key, required this.level});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late ConfettiController _confettiController;
  int _currentExerciseIndex = 0;

  // Speech practice state
  String _spokenText = '';
  double _similarityScore = 0.0;
  bool _hasEvaluated = false;

  // Multiple choice state
  int? _selectedOptionIndex;
  bool _hasAnsweredChoice = false;

  bool _isLevelFinished = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Play initial audio for first exercise automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playCurrentPhraseAudio();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  ExerciseItem get _currentExercise => widget.level.exercises[_currentExerciseIndex];

  Future<void> _playCurrentPhraseAudio() async {
    final tts = context.read<ArabicTtsService>();
    final dialect = context.read<AppStateProvider>().activeDialect;
    await tts.speak(_currentExercise.arabicPhrase, dialect: dialect);
  }

  Future<void> _startRecordingSpeech() async {
    final tts = context.read<ArabicTtsService>();
    final speech = context.read<ArabicSpeechService>();
    final dialect = context.read<AppStateProvider>().activeDialect;

    await AudioFocusGuard.prepareForStt(
      stopTtsAction: () => tts.stop(),
    );

    setState(() {
      _spokenText = '';
      _hasEvaluated = false;
    });

    await speech.startListening(
      dialect: dialect,
      onResultCallback: (words, isFinal) {
        if (!mounted) return;
        setState(() => _spokenText = words);

        if (isFinal && words.trim().isNotEmpty) {
          _evaluateSpeech(words);
        }
      },
    );
  }

  Future<void> _evaluateSpeech(String words) async {
    final speech = context.read<ArabicSpeechService>();
    await speech.cancelListening();

    final score = ArabicSimilarity.calculateSimilarity(words, _currentExercise.arabicPhrase);
    setState(() {
      _similarityScore = score;
      _hasEvaluated = true;
    });
  }

  void _selectChoiceOption(int index) {
    if (_hasAnsweredChoice) return;
    setState(() {
      _selectedOptionIndex = index;
      _hasAnsweredChoice = true;
    });
  }

  Future<void> _nextExercise() async {
    final speech = context.read<ArabicSpeechService>();
    final curriculum = context.read<CurriculumProvider>();
    await speech.cancelListening();

    if (!mounted) return;

    if (_currentExerciseIndex < widget.level.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _spokenText = '';
        _similarityScore = 0.0;
        _hasEvaluated = false;
        _selectedOptionIndex = null;
        _hasAnsweredChoice = false;
      });
      _playCurrentPhraseAudio();
    } else {
      // Level completed!
      await curriculum.completeLevel(widget.level.levelNumber, 3);
      if (!mounted) return;
      _confettiController.play();
      setState(() => _isLevelFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final speech = context.watch<ArabicSpeechService>();
    final totalExercises = widget.level.exercises.length;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Text('Level ${widget.level.levelNumber}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                // Top Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Exercise ${_currentExerciseIndex + 1} of $totalExercises',
                            style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast),
                          ),
                          Text(
                            widget.level.tierTitle,
                            style: AppTheme.latin(fontSize: 13, color: AppColors.emeraldLight, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (_currentExerciseIndex + 1) / totalExercises,
                        backgroundColor: AppColors.slateBorder,
                        color: AppColors.emeraldPrimary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: _isLevelFinished
                      ? _buildLevelCompletedView()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: _currentExercise.type == ExerciseType.speechPractice
                              ? _buildSpeechPracticeCard(speech.isListening)
                              : _buildDialectEquivalenceCard(),
                        ),
                ),

                // Bottom Action Button
                if (!_isLevelFinished)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_currentExercise.type == ExerciseType.speechPractice
                                ? _hasEvaluated
                                : _hasAnsweredChoice)
                            ? _nextExercise
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _currentExerciseIndex < totalExercises - 1 ? 'Next Exercise' : 'Complete Level',
                          style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
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

  Widget _buildSpeechPracticeCard(bool isListening) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            children: [
              // Arabic Phrase (Rule 3: Wrapped in RTL Directionality)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  _currentExercise.arabicPhrase,
                  textAlign: TextAlign.center,
                  style: AppTheme.arabic(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),

              // Phonetic Guide (Rule 3: Wrapped in LTR Directionality, Rule 6: NotoSans)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  _currentExercise.phoneticGuide,
                  textAlign: TextAlign.center,
                  style: AppTheme.phonetic(fontSize: 15, color: AppColors.amberLight),
                ),
              ),
              const SizedBox(height: 6),

              // English Translation
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '"${_currentExercise.englishMeaning}"',
                  textAlign: TextAlign.center,
                  style: AppTheme.latin(fontSize: 14, color: AppColors.textMediumContrast),
                ),
              ),
              const SizedBox(height: 16),

              // Replay Audio Button
              ElevatedButton.icon(
                onPressed: _playCurrentPhraseAudio,
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('Listen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slateCardElevated,
                  foregroundColor: AppColors.emeraldLight,
                  side: const BorderSide(color: AppColors.emeraldPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Mic Speaking Orb
        GestureDetector(
          onTap: _startRecordingSpeech,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? AppColors.amberWarm : AppColors.emeraldPrimary,
              boxShadow: [
                BoxShadow(
                  color: isListening ? AppColors.amberGlow : AppColors.emeraldGlow,
                  blurRadius: isListening ? 20 : 10,
                  spreadRadius: isListening ? 6 : 2,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: isListening ? Colors.black : Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isListening ? 'Listening to your Arabic pronunciation...' : 'Tap mic to pronounce the phrase',
          style: AppTheme.latin(
            fontSize: 13,
            color: isListening ? AppColors.amberWarm : AppColors.textMediumContrast,
          ),
        ),
        const SizedBox(height: 16),

        // Spoken transcript and accuracy card
        if (_spokenText.isNotEmpty || _hasEvaluated)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.midnightSand,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasEvaluated
                    ? (_similarityScore >= 0.5 ? AppColors.emeraldPrimary : AppColors.amberWarm)
                    : AppColors.slateBorder,
              ),
            ),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    _spokenText,
                    textAlign: TextAlign.center,
                    style: AppTheme.arabic(fontSize: 16, color: Colors.white),
                  ),
                ),
                if (_hasEvaluated) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${(_similarityScore * 100).toInt()}% Match • ${_similarityScore >= 0.5 ? "Mumtaz! (Excellent)" : "Try again for a higher score"}',
                    style: AppTheme.latin(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _similarityScore >= 0.5 ? AppColors.emeraldLight : AppColors.amberWarm,
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Cultural tip
        if (_currentExercise.culturalTip != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slateCardElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: AppColors.amberLight, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentExercise.culturalTip!,
                    style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDialectEquivalenceCard() {
    final options = _currentExercise.options ?? [];
    final correctIdx = _currentExercise.correctOptionIndex ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.slateCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dialect Equivalence Challenge',
                style: AppTheme.latin(fontSize: 13, color: AppColors.emeraldLight, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _currentExercise.question ?? 'Choose the correct dialect equivalent:',
                style: AppTheme.latin(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Multiple choice options
        ...List.generate(options.length, (idx) {
          final option = options[idx];
          final isSelected = _selectedOptionIndex == idx;
          final isCorrect = idx == correctIdx;

          Color borderColor = AppColors.slateBorder;
          Color bgColor = AppColors.slateCard;
          if (_hasAnsweredChoice) {
            if (isCorrect) {
              borderColor = AppColors.emeraldPrimary;
              bgColor = AppColors.emeraldDark.withValues(alpha: 0.5);
            } else if (isSelected) {
              borderColor = AppColors.crimsonHeart;
              bgColor = AppColors.crimsonGlow;
            }
          }

          return GestureDetector(
            onTap: () => _selectChoiceOption(idx),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + idx), // A, B, C, D
                        style: AppTheme.latin(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        option,
                        style: AppTheme.arabic(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (_hasAnsweredChoice && isCorrect)
                    const Icon(Icons.check_circle, color: AppColors.emeraldPrimary, size: 20)
                  else if (_hasAnsweredChoice && isSelected && !isCorrect)
                    const Icon(Icons.cancel, color: AppColors.crimsonHeart, size: 20),
                ],
              ),
            ),
          );
        }),

        if (_hasAnsweredChoice && _currentExercise.culturalTip != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slateCardElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentExercise.culturalTip!,
              style: AppTheme.latin(fontSize: 12, color: AppColors.amberLight),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLevelCompletedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.military_tech, color: AppColors.amberWarm, size: 72),
            const SizedBox(height: 16),
            Text(
              'Level Completed! مبروك',
              style: AppTheme.latin(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.level.title,
              textAlign: TextAlign.center,
              style: AppTheme.latin(fontSize: 15, color: AppColors.textMediumContrast),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (_) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star, color: AppColors.amberWarm, size: 36),
                );
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Curriculum'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
