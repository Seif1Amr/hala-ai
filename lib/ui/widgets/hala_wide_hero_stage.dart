import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/dialect.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/conversation_provider.dart';
import 'sound_wave_animator.dart';

class HalaWideHeroStage extends StatelessWidget {
  final HalaAvatarState avatarState;
  final DialectType dialect;
  final String statusText;
  final VoidCallback? onDialectTap;
  final bool isListening;

  const HalaWideHeroStage({
    super.key,
    required this.avatarState,
    required this.dialect,
    required this.statusText,
    this.onDialectTap,
    this.isListening = false,
  });

  String _getAvatarAsset() {
    switch (avatarState) {
      case HalaAvatarState.speaking:
        return 'assets/avatars/avatar_hala_speaking.jpg';
      case HalaAvatarState.thinking:
        return 'assets/avatars/avatar_hala_thinking.jpg';
      case HalaAvatarState.celebrating:
        return 'assets/avatars/avatar_hala_celebrating.jpg';
      case HalaAvatarState.neutral:
        return 'assets/avatars/avatar_hala_neutral.jpg';
    }
  }

  Color _getBorderColor() {
    if (isListening) {
      return AppColors.amberWarm;
    }
    switch (avatarState) {
      case HalaAvatarState.speaking:
      case HalaAvatarState.celebrating:
        return AppColors.emeraldPrimary;
      case HalaAvatarState.thinking:
        return const Color(0xFFA855F7); // Electric Violet
      case HalaAvatarState.neutral:
        return AppColors.slateBorder;
    }
  }

  Color _getGlowColor() {
    if (isListening) {
      return AppColors.amberGlow;
    }
    switch (avatarState) {
      case HalaAvatarState.speaking:
      case HalaAvatarState.celebrating:
        return AppColors.emeraldGlow;
      case HalaAvatarState.thinking:
        return const Color(0x44A855F7);
      case HalaAvatarState.neutral:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor();
    final glowColor = _getGlowColor();
    final isSpeaking = avatarState == HalaAvatarState.speaking;
    final isWaveActive = isSpeaking || isListening;

    final appState = context.watch<AppStateProvider?>();
    final appLang = appState?.displayLanguage ?? 'en';
    final isArabic = appLang == 'ar';
    final characterName = AppStrings.get('characterName', lang: appLang);
    final roleName = AppStrings.get('characterRole', lang: appLang);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final stageHeight = constraints.maxWidth > 650
            ? 350.0
            : (screenHeight * 0.32).clamp(280.0, 320.0);

        return Container(
          width: double.infinity,
          height: stageHeight,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
            // Avatar Background Photo - Extended and framed to show Hala's face clearly
            Positioned.fill(
              child: Image.asset(
                _getAvatarAsset(),
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.55), // Perfectly frames face with dark space on top
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.slateCard,
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 72,
                        color: AppColors.emeraldLight,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Top HUD Subtle Gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x990B0F17),
                      Color(0x000B0F17),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom HUD Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC0B0F17),
                      Color(0x000B0F17),
                    ],
                  ),
                ),
              ),
            ),

            // TOP HUD: Compact Status Badge in dark upper area above hair
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.obsidianBase.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: borderColor,
                        boxShadow: [
                          BoxShadow(color: borderColor, blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText.contains('•') ? statusText.split('•').first.trim() : statusText,
                      style: isArabic
                          ? AppTheme.arabic(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                            )
                          : AppTheme.latin(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM HUD: Title 'Hala'/'حلا', Badge, and Equalizer Wave
            Positioned(
              bottom: 10,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        characterName,
                        style: isArabic
                            ? AppTheme.arabic(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )
                            : AppTheme.latin(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldDark.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.emeraldPrimary, width: 0.8),
                        ),
                        child: Text(
                          roleName,
                          style: isArabic
                              ? AppTheme.arabic(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emeraldLight,
                                )
                              : AppTheme.latin(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emeraldLight,
                                  letterSpacing: 0.5,
                                ),
                        ),
                      ),
                    ],
                  ),

                  // 4-Bar Equalizer Waves Visualizer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.slateCard.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SoundWaveAnimator(
                      isAnimating: isWaveActive,
                      waveColor: isListening ? AppColors.amberWarm : AppColors.emeraldLight,
                      height: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
