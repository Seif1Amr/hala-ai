import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dialect.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/active_recall_ad_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // NEVER display raw API key in UI
    _apiKeyController.text = '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final key = _apiKeyController.text.trim();
    if (key.isNotEmpty) {
      final gemini = context.read<GeminiService>();
      gemini.setApiKey(key);
      _apiKeyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google AI Studio API key updated and active!'),
          backgroundColor: AppColors.emeraldPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final gemini = context.watch<GeminiService>();
    final wallet = context.watch<MonetizationProvider>();
    final conversation = context.watch<ConversationProvider>();
    final appLang = appState.displayLanguage;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Text(AppStrings.get('navSettings', lang: appLang)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
            // Display Language Section (Rule 3)
            _buildSectionHeader('Display Interface Language (Rule 3)'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.slateCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slateBorder),
              ),
              child: Column(
                children: [
                  _buildLanguageRadio('English (Default)', 'en', appState),
                  const Divider(color: AppColors.slateDivider, height: 1),
                  _buildLanguageRadio('العربية (Arabic)', 'ar', appState),
                  const Divider(color: AppColors.slateDivider, height: 1),
                  _buildLanguageRadio('Deutsch (German)', 'de', appState),
                  const Divider(color: AppColors.slateDivider, height: 1),
                  _buildLanguageRadio('Français (French)', 'fr', appState),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Dialect Section
            _buildSectionHeader('Active Arabic Dialect Focus'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.slateCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slateBorder),
              ),
              child: Column(
                children: DialectType.values.map((dialect) {
                  final isSel = dialect == appState.activeDialect;
                  return Column(
                    children: [
                      ListTile(
                        leading: Text(dialect.flag, style: const TextStyle(fontSize: 24)),
                        title: Text(dialect.arabicName, style: AppTheme.arabic(fontSize: 15)),
                        subtitle: Text(dialect.englishName, style: AppTheme.latin(fontSize: 12, color: AppColors.textMuted)),
                        trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.emeraldPrimary) : null,
                        onTap: () {
                          appState.setActiveDialect(dialect);
                          conversation.setDialect(dialect);
                        },
                      ),
                      if (dialect != DialectType.values.last)
                        const Divider(color: AppColors.slateDivider, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Gemini 2.0 Flash Client Engine
            _buildSectionHeader('AI Conversational Engine'),
            Container(
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
                        'Direct Client Model',
                        style: AppTheme.latin(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gemini.activeModelName,
                          style: AppTheme.latin(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powers both Gemini 2.0 Flash reasoning and Google AI Studio native human dialect speech generation (Aoede voice). Zero robot TTS when active.',
                    style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: AppTheme.latin(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Google AI Studio API Key',
                      labelStyle: AppTheme.latin(fontSize: 13, color: AppColors.textMuted),
                      hintText: gemini.hasCustomKey
                          ? '•••••••••••••••••••••••• (Active)'
                          : 'Enter API Key from aistudio.google.com',
                      hintStyle: AppTheme.latin(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.midnightSand,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: AppColors.emeraldLight),
                        onPressed: _saveApiKey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gemini.hasCustomKey
                        ? 'Active: Google AI Studio conversational intelligence & human voice enabled.'
                        : 'Get a free key from aistudio.google.com or paste it to the assistant to activate studio human voice.',
                    style: AppTheme.latin(
                      fontSize: 11,
                      color: gemini.hasCustomKey ? AppColors.emeraldLight : AppColors.amberLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Recall Ad-Bridge Wallet Info (Rule 4: Zero PRO Badges)
            _buildSectionHeader('Hearts & Active Recall Wallet (100% Free)'),
            Container(
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
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.crimsonHeart, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Current Wallet Balance',
                            style: AppTheme.latin(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '${wallet.hearts} Hearts',
                        style: AppTheme.latin(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Speaking turns cost 1 Heart. Refill +15 Hearts anytime by completing a 10-second Active Recall dialect speaking challenge.',
                    style: AppTheme.latin(fontSize: 12, color: AppColors.textMediumContrast),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => ActiveRecallAdDialog.show(context),
                      icon: const Icon(Icons.favorite, size: 16),
                      label: const Text('Practice & Refill +15 Hearts'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App Metadata
            Center(
              child: Column(
                children: [
                  Text(
                    'Hala AI Learning Arabic v1.0.0',
                    style: AppTheme.latin(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Package: com.wsotech.halaaiarabic',
                    style: AppTheme.latin(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTheme.latin(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.emeraldLight,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLanguageRadio(String label, String code, AppStateProvider state) {
    final isSel = state.displayLanguage == code;
    return ListTile(
      title: Text(
        label,
        style: AppTheme.latin(
          fontSize: 14,
          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
          color: isSel ? Colors.white : AppColors.textHighContrast,
        ),
      ),
      trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.emeraldPrimary) : null,
      onTap: () => state.setDisplayLanguage(code),
    );
  }
}
