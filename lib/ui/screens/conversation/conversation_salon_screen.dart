import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/dialect.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/conversation_provider.dart';
import '../../../providers/monetization_provider.dart';
import '../../widgets/active_recall_ad_dialog.dart';
import '../../widgets/dialect_selector_pill.dart';
import '../../widgets/hala_wide_hero_stage.dart';
import '../../widgets/hearts_counter_widget.dart';

class ConversationSalonScreen extends StatefulWidget {
  const ConversationSalonScreen({super.key});

  @override
  State<ConversationSalonScreen> createState() => _ConversationSalonScreenState();
}

class _ConversationSalonScreenState extends State<ConversationSalonScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showPhonetics = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleOutOfHearts() {
    ActiveRecallAdDialog.show(context);
  }

  Future<void> _handleTextSubmit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final conversation = context.read<ConversationProvider>();
    await conversation.submitUserTurn(text, onOutOfHearts: _handleOutOfHearts);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = context.watch<ConversationProvider>();
    final speech = context.watch<ArabicSpeechService>();
    final wallet = context.watch<MonetizationProvider>();
    final appState = context.watch<AppStateProvider>();
    final appLang = appState.displayLanguage;

    final activeDialect = conversation.activeDialect;
    final isListening = speech.isListening;

    // Scroll to bottom when message arrives
    _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        title: Text(AppStrings.get('navConversation', lang: appLang)),
        actions: [
          // Hearts counter with refill action
          HeartsCounterWidget(
            hearts: wallet.hearts,
            onTap: () => ActiveRecallAdDialog.show(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _showPhonetics ? Icons.subtitles : Icons.subtitles_off,
              color: _showPhonetics ? AppColors.emeraldLight : AppColors.textMuted,
            ),
            tooltip: 'Toggle Phonetic Arabizi',
            onPressed: () => setState(() => _showPhonetics = !_showPhonetics),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              children: [
                // RULE 2: Widescreen Hero Stage (HalaWideHeroStage)
                HalaWideHeroStage(
                  avatarState: conversation.avatarState,
                  dialect: activeDialect,
                  statusText: conversation.hudStatus,
                  isListening: isListening,
                  onDialectTap: () => _showDialectPickerModal(context),
                ),
                const SizedBox(height: 6),

                // Dialect Selector Segmented Pill placed UNDER the avatar
                DialectSelectorPill(
                  activeDialect: activeDialect,
                  onDialectChanged: (d) {
                    conversation.setDialect(d);
                    appState.setActiveDialect(d);
                  },
                ),

                // Live Speech Recognition Subtitle Banner (when mic is active)
                if (isListening && speech.currentWords.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.amberWarm.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amberWarm, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: AppColors.amberWarm, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            speech.currentWords,
                            style: AppTheme.arabic(fontSize: 14, color: AppColors.amberLight),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Conversation Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: conversation.messages.length + (conversation.isAiThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == conversation.messages.length && conversation.isAiThinking) {
                        return _buildThinkingSkeletonBubble(activeDialect);
                      }
                      final message = conversation.messages[index];
                      return _buildMessageBubble(message, conversation);
                    },
                  ),
                ),

                // Quick Topic Suggestion Chips
                _buildQuickTopicSuggestions(activeDialect, conversation),

                // Bottom Input Controls: Mic Orb + Text Field
                _buildBottomInputArea(conversation, speech),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ConversationProvider conv) {
    final isHala = msg.isFromHala;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isHala ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHala) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emeraldPrimary, width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/avatars/avatar_hala_neutral.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isHala ? AppColors.slateCardElevated : AppColors.emeraldDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isHala ? 4 : 16),
                  bottomRight: Radius.circular(isHala ? 16 : 4),
                ),
                border: Border.all(
                  color: isHala ? AppColors.slateBorder : AppColors.emeraldPrimary,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: isHala ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  // Arabic dialect text (Rule 3: Wrapped in RTL Directionality)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      msg.text,
                      style: AppTheme.arabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Optional Correction in Subtle Bracket
                  if (msg.correction != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amberWarm.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.amberWarm.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        msg.correction!,
                        style: AppTheme.arabic(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.amberLight,
                        ),
                      ),
                    ),
                  ],

                  // Hala Audio Replay Button
                  if (isHala) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => conv.replayMessage(msg),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              const Icon(Icons.volume_up, size: 15, color: AppColors.emeraldLight),
                              const SizedBox(width: 4),
                              Text(
                                'Replay',
                                style: AppTheme.latin(
                                  fontSize: 11,
                                  color: AppColors.emeraldLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          msg.dialect.shortArabicName,
                          style: AppTheme.arabic(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!isHala) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildThinkingSkeletonBubble(DialectType dialect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA855F7), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/avatars/avatar_hala_thinking.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.psychology, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.slateCardElevated,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'حلا تحضّر الرد...',
                  style: AppTheme.arabic(
                    fontSize: 13,
                    color: AppColors.textMediumContrast,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTopicSuggestions(DialectType dialect, ConversationProvider conv) {
    List<String> prompts;
    switch (dialect) {
      case DialectType.egyptian:
        prompts = [
          'إزيك يا باشا؟ عامل إيه؟',
          'عاوز أطلب قهوة مظبوطة',
          'كام الحساب لو سمحت؟',
        ];
        break;
      case DialectType.saudi:
        prompts = [
          'يا هلا والله! وش مسوي اليوم؟',
          'وش تنصحني أطلب عشاء؟',
          'طال عمرك، وين أقرب بنك؟',
        ];
        break;
      case DialectType.emirati:
        prompts = [
          'مرحبا الساع! شحالك عساك بخير؟',
          'شو رايك نشرب كرك الحين؟',
          'ما قصرت والله فديتك',
        ];
        break;
    }

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: AppColors.slateCardElevated,
              side: const BorderSide(color: AppColors.slateBorder),
              label: Text(
                prompt,
                style: AppTheme.arabic(fontSize: 12, color: AppColors.textHighContrast),
              ),
              onPressed: () {
                _textController.text = prompt;
                _handleTextSubmit();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomInputArea(ConversationProvider conv, ArabicSpeechService speech) {
    final isListening = speech.isListening;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.midnightSand,
        border: Border(top: BorderSide(color: AppColors.slateBorder, width: 1)),
      ),
      child: Row(
        children: [
          // Mic Orb Button obeying Rule 1
          GestureDetector(
            onTap: () => conv.handleMicOrbTap(onOutOfHearts: _handleOutOfHearts),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? AppColors.amberWarm : AppColors.emeraldPrimary,
                boxShadow: [
                  BoxShadow(
                    color: isListening ? AppColors.amberGlow : AppColors.emeraldGlow,
                    blurRadius: isListening ? 18 : 8,
                    spreadRadius: isListening ? 4 : 1,
                  ),
                ],
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.black : Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text Field for Quiet Typing
          Expanded(
            child: TextField(
              controller: _textController,
              textDirection: TextDirection.rtl, // Arabic input
              style: AppTheme.arabic(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك لحلا...',
                hintStyle: AppTheme.arabic(fontSize: 14, color: AppColors.textMuted),
                hintTextDirection: TextDirection.rtl,
                filled: true,
                fillColor: AppColors.slateCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.slateBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.slateBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.emeraldPrimary),
                ),
              ),
              onSubmitted: (_) => _handleTextSubmit(),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.emeraldLight),
            onPressed: _handleTextSubmit,
          ),
        ],
      ),
    );
  }

  void _showDialectPickerModal(BuildContext context) {
    final conv = context.read<ConversationProvider>();
    final appState = context.read<AppStateProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Active Dialect',
                style: AppTheme.latin(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              ...DialectType.values.map((dialect) {
                final isSel = dialect == conv.activeDialect;
                return ListTile(
                  leading: Text(dialect.flag, style: const TextStyle(fontSize: 26)),
                  title: Text(dialect.arabicName, style: AppTheme.arabic(fontSize: 16)),
                  subtitle: Text(dialect.description, style: AppTheme.latin(fontSize: 12, color: AppColors.textMuted)),
                  trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.emeraldPrimary) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: isSel ? AppColors.slateCardElevated : null,
                  onTap: () {
                    conv.setDialect(dialect);
                    appState.setActiveDialect(dialect);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
