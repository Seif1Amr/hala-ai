import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dialect_matrix.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/stt_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/arabic_similarity.dart';
import '../../core/utils/audio_focus_guard.dart';
import '../../data/models/dialect.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/monetization_provider.dart';

enum AdBridgeStep {
  preview,
  playingAd,
  speechCheck,
  success,
}

class ActiveRecallAdDialog extends StatefulWidget {
  final DialectType dialect;

  const ActiveRecallAdDialog({super.key, required this.dialect});

  static Future<void> show(BuildContext context) {
    final dialect = context.read<AppStateProvider>().activeDialect;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActiveRecallAdDialog(dialect: dialect),
    );
  }

  @override
  State<ActiveRecallAdDialog> createState() => _ActiveRecallAdDialogState();
}

class _ActiveRecallAdDialogState extends State<ActiveRecallAdDialog> {
  late ConfettiController _confettiController;
  late DialectMatrixItem _challengeItem;
  AdBridgeStep _currentStep = AdBridgeStep.preview;

  String _spokenText = '';
  double _similarityScore = 0.0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    final wallet = context.read<MonetizationProvider>();
    _challengeItem = wallet.getRandomChallengePhrase(widget.dialect);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _playPhraseAudio() async {
    final tts = context.read<ArabicTtsService>();
    final targetPhrase = _challengeItem.getPhraseFor(widget.dialect);
    await tts.speak(targetPhrase, dialect: widget.dialect);
  }

  Future<void> _startAdSequence() async {
    final tts = context.read<ArabicTtsService>();
    final adService = context.read<AdService>();

    // Step 2: Pre-ad audio demonstration
    final targetPhrase = _challengeItem.getPhraseFor(widget.dialect);
    await tts.speak(targetPhrase, dialect: widget.dialect);

    setState(() => _currentStep = AdBridgeStep.playingAd);

    // Step 3: Sponsor Ad playback
    await adService.playRewardedAd(
      onRewardEarned: () {
        debugPrint('[AdBridge] Ad watched, pre-warming STT...');
      },
    );

    // Step 4: Immediate Post-Ad Speech Check
    if (mounted) {
      setState(() => _currentStep = AdBridgeStep.speechCheck);
      _openMicForSpeechCheck();
    }
  }

  Future<void> _openMicForSpeechCheck() async {
    final tts = context.read<ArabicTtsService>();
    final speech = context.read<ArabicSpeechService>();

    await AudioFocusGuard.prepareForStt(
      stopTtsAction: () => tts.stop(),
    );

    setState(() {
      _spokenText = '';
    });

    final targetPhrase = _challengeItem.getPhraseFor(widget.dialect);

    await speech.startListening(
      dialect: widget.dialect,
      onResultCallback: (words, isFinal) {
        if (!mounted) return;
        setState(() => _spokenText = words);

        if (isFinal && words.trim().isNotEmpty) {
          _evaluateSpokenPhrase(words, targetPhrase);
        }
      },
    );
  }

  Future<void> _evaluateSpokenPhrase(String spoken, String target) async {
    final speech = context.read<ArabicSpeechService>();
    final wallet = context.read<MonetizationProvider>();
    await speech.cancelListening();

    if (!mounted) return;

    final score = ArabicSimilarity.calculateSimilarity(spoken, target);
    _similarityScore = score;

    // Generous threshold for encouragement (50% or above passes)
    if (score >= 0.50 || spoken.trim().length >= 4) {
      await wallet.grantAdBridgeRefuel();

      if (!mounted) return;
      _confettiController.play();
      setState(() => _currentStep = AdBridgeStep.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLang = context.watch<AppStateProvider>().displayLanguage;
    final targetPhrase = _challengeItem.getPhraseFor(widget.dialect);
    final phonetic = _challengeItem.getPhoneticFor(widget.dialect);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          backgroundColor: AppColors.slateCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.slateBorder, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(appLang),
                const SizedBox(height: 18),
                _buildStepContent(targetPhrase, phonetic, appLang),
              ],
            ),
          ),
        ),

        // Confetti Celebration
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
    );
  }

  Widget _buildHeader(String appLang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.crimsonGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.crimsonHeart, width: 1),
              ),
              child: const Icon(Icons.favorite, color: AppColors.crimsonHeart, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              '+15 Hearts Refuel',
              style: AppTheme.latin(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (_currentStep != AdBridgeStep.playingAd)
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }

  Widget _buildStepContent(String targetPhrase, String phonetic, String appLang) {
    switch (_currentStep) {
      case AdBridgeStep.preview:
        return Column(
          children: [
            Text(
              'Active Recall Practice',
              style: AppTheme.latin(fontSize: 14, color: AppColors.emeraldLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Rehearse this authentic dialect phrase. Watch a sponsor clip, then repeat it out loud to claim +15 Hearts!',
              textAlign: TextAlign.center,
              style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast),
            ),
            const SizedBox(height: 16),

            // Target Phrase Card (RTL for Arabic, LTR for Phonetics per Rule 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.midnightSand,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      targetPhrase,
                      textAlign: TextAlign.center,
                      style: AppTheme.arabic(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      phonetic,
                      textAlign: TextAlign.center,
                      style: AppTheme.phonetic(fontSize: 14, color: AppColors.amberLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '"${_challengeItem.conceptEn}"',
                      textAlign: TextAlign.center,
                      style: AppTheme.latin(fontSize: 13, color: AppColors.textMediumContrast),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _playPhraseAudio,
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Listen to Hala'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slateCardElevated,
                      foregroundColor: AppColors.emeraldLight,
                      side: const BorderSide(color: AppColors.emeraldPrimary, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startAdSequence,
                icon: const Icon(Icons.play_circle_fill, size: 20),
                label: const Text('Start Challenge & Ad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        );

      case AdBridgeStep.playingAd:
        return Column(
          children: [
            const CircularProgressIndicator(color: AppColors.amberWarm),
            const SizedBox(height: 18),
            Text(
              'Playing Sponsor Ad...',
              style: AppTheme.latin(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Rehearse mentally in your mind:\n"$targetPhrase"',
              textAlign: TextAlign.center,
              style: AppTheme.arabic(fontSize: 15, color: AppColors.amberLight),
            ),
          ],
        );

      case AdBridgeStep.speechCheck:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amberWarm.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.amberWarm),
              ),
              child: Text(
                'تكلم الآن! • Speak Now!',
                style: AppTheme.arabic(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.amberWarm),
              ),
            ),
            const SizedBox(height: 14),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                targetPhrase,
                textAlign: TextAlign.center,
                style: AppTheme.arabic(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                phonetic,
                textAlign: TextAlign.center,
                style: AppTheme.phonetic(fontSize: 13, color: AppColors.textMediumContrast),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.midnightSand,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slateBorder),
              ),
              child: Text(
                _spokenText.isEmpty ? 'Say the phrase out loud...' : _spokenText,
                textAlign: TextAlign.center,
                style: AppTheme.arabic(
                  fontSize: 16,
                  color: _spokenText.isEmpty ? AppColors.textMuted : AppColors.emeraldLight,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _openMicForSpeechCheck,
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _evaluateSpokenPhrase(_spokenText, targetPhrase),
                    child: const Text('Check'),
                  ),
                ),
              ],
            ),
          ],
        );

      case AdBridgeStep.success:
        return Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.emeraldPrimary, size: 54),
            const SizedBox(height: 12),
            Text(
              'Mabrook! مبروك!',
              style: AppTheme.arabic(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
            ),
            const SizedBox(height: 6),
            Text(
              '${(_similarityScore * 100).toInt()}% Pronunciation Accuracy',
              style: AppTheme.latin(fontSize: 14, color: AppColors.amberLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.emeraldDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.emeraldPrimary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: AppColors.crimsonHeart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+15 Hearts Added to Wallet',
                    style: AppTheme.latin(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Learning'),
              ),
            ),
          ],
        );
    }
  }
}
