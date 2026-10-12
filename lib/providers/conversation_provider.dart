import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/gemini_service.dart';
import '../core/services/stt_service.dart';
import '../core/services/tts_service.dart';
import '../core/utils/audio_focus_guard.dart';
import '../data/models/chat_message.dart';
import '../data/models/dialect.dart';
import 'monetization_provider.dart';

enum HalaAvatarState {
  neutral,
  speaking,
  thinking,
  celebrating,
}

class ConversationProvider extends ChangeNotifier {
  final GeminiService _geminiService;
  final ArabicTtsService _ttsService;
  final ArabicSpeechService _speechService;
  final MonetizationProvider _monetizationProvider;

  // RULE 1: Atomic submission locks
  bool _isSubmittingTurn = false;
  String? _lastSubmittedText;
  DateTime? _lastSubmitTime;

  bool _isAiThinking = false;
  bool get isAiThinking => _isAiThinking;

  HalaAvatarState _avatarState = HalaAvatarState.neutral;
  HalaAvatarState get avatarState => _avatarState;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  DialectType _activeDialect = DialectType.saudi;
  DialectType get activeDialect => _activeDialect;

  // Status message in HUD
  String _hudStatus = 'Online • Gemini 2.0 Flash';
  String get hudStatus => _hudStatus;

  ConversationProvider({
    required GeminiService geminiService,
    required ArabicTtsService ttsService,
    required ArabicSpeechService speechService,
    required MonetizationProvider monetizationProvider,
  })  : _geminiService = geminiService,
        _ttsService = ttsService,
        _speechService = speechService,
        _monetizationProvider = monetizationProvider {
    _initInitialGreeting();
  }

  void setDialect(DialectType dialect) {
    if (_activeDialect == dialect) return;
    _activeDialect = dialect;
    _geminiService.initChatForDialect(dialect);
    _initInitialGreeting();
    notifyListeners();
  }

  void _initInitialGreeting() {
    _messages.clear();
    final greeting = _activeDialect.greetingPhrase;
    _messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: greeting,
        sender: MessageSender.hala,
        timestamp: DateTime.now(),
        dialect: _activeDialect,
      ),
    );
    _avatarState = HalaAvatarState.neutral;
    _hudStatus = 'Online • ${_geminiService.activeModelName}';
    notifyListeners();
  }

  /// Mic orb tap handler obeying RULE 1
  Future<void> handleMicOrbTap({required VoidCallback onOutOfHearts}) async {
    if (_speechService.isListening) {
      final captured = _speechService.currentWords.trim();
      // RULE 1 CRITICAL: Use cancelListening(), NEVER stopListening() here!
      await _speechService.cancelListening();
      if (captured.isNotEmpty) {
        await submitUserTurn(captured, onOutOfHearts: onOutOfHearts);
      } else {
        _avatarState = HalaAvatarState.neutral;
        _hudStatus = 'Online • ${_geminiService.activeModelName}';
        notifyListeners();
      }
      return;
    }

    // Check hearts before opening mic
    if (_monetizationProvider.hearts <= 0) {
      onOutOfHearts();
      return;
    }

    // RULE 7: Audio interlock - TTS must completely stop before opening microphone
    await AudioFocusGuard.prepareForStt(
      stopTtsAction: () => _ttsService.stop(),
    );

    _avatarState = HalaAvatarState.neutral;
    _hudStatus = 'حلا تسمعك...';
    notifyListeners();

    await _speechService.startListening(
      dialect: _activeDialect,
      onResultCallback: (words, isFinal) {
        if (isFinal && words.trim().isNotEmpty) {
          submitUserTurn(words.trim(), onOutOfHearts: onOutOfHearts);
        }
      },
    );
  }

  /// RULE 1: Core atomic turn submission handler
  Future<void> submitUserTurn(
    String text, {
    required VoidCallback onOutOfHearts,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    // MUTEX GUARD: Drop duplicate or overlapping turns immediately
    if (_isSubmittingTurn || _isAiThinking) {
      debugPrint('[HalaAI] Dropped concurrent turn submission: "$cleanText"');
      return;
    }

    // RAPID DEBOUNCE: Drop identical speech within 2,500ms
    final now = DateTime.now();
    if (_lastSubmittedText == cleanText &&
        _lastSubmitTime != null &&
        now.difference(_lastSubmitTime!).inMilliseconds < 2500) {
      debugPrint('[HalaAI] Dropped rapid duplicate phrase: "$cleanText"');
      return;
    }

    _isSubmittingTurn = true;
    _lastSubmittedText = cleanText;
    _lastSubmitTime = now;

    // Immediately cancel microphone to flush & kill any trailing recognizer events
    try {
      await _speechService.cancelListening();
    } catch (_) {}

    try {
      // Deduct 1 Heart ONCE
      final deducted = _monetizationProvider.deductSpeakingTurnHeart();
      if (!deducted) {
        onOutOfHearts();
        return;
      }

      // Add user message to conversation list
      final userMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_u',
        text: cleanText,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
        dialect: _activeDialect,
      );
      _messages.add(userMsg);

      // Transition avatar to Thinking state
      _isAiThinking = true;
      _avatarState = HalaAvatarState.thinking;
      _hudStatus = 'حلا تفكر...';
      notifyListeners();

      // Call Gemini 2.0 Flash
      final aiReply = await _geminiService.sendMessage(
        cleanText,
        dialect: _activeDialect,
      );

      _isAiThinking = false;

      // Extract optional correction bracket if returned
      String? correction;
      String cleanReply = aiReply;
      final correctionRegex = RegExp(r'\[(.*?)\]');
      final match = correctionRegex.firstMatch(aiReply);
      if (match != null) {
        correction = match.group(1);
        cleanReply = aiReply.replaceAll(correctionRegex, '').trim();
      }

      final halaMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_h',
        text: cleanReply.isNotEmpty ? cleanReply : aiReply,
        sender: MessageSender.hala,
        timestamp: DateTime.now(),
        dialect: _activeDialect,
        correction: correction,
      );
      _messages.add(halaMsg);

      // RULE 7: Audio interlock - microphone canceled before TTS speaks
      await AudioFocusGuard.prepareForTts(
        cancelSttAction: () => _speechService.cancelListening(),
      );

      // Transition avatar to Speaking state
      _avatarState = HalaAvatarState.speaking;
      _hudStatus = 'حلا تتحدث...';
      notifyListeners();

      // Play audio response with native Arabic TTS
      await _ttsService.speak(cleanReply.isNotEmpty ? cleanReply : aiReply, dialect: _activeDialect);

      _avatarState = HalaAvatarState.neutral;
      _hudStatus = 'Online • ${_geminiService.activeModelName}';
      notifyListeners();
    } catch (e) {
      debugPrint('[HalaAI] Turn processing error: $e');
      _avatarState = HalaAvatarState.neutral;
      _hudStatus = 'Online • ${_geminiService.activeModelName}';
      notifyListeners();
    } finally {
      // ALWAYS reset lock in finally block (RULE 1)
      _isSubmittingTurn = false;
      _isAiThinking = false;
    }
  }

  /// Replay audio for a specific message
  Future<void> replayMessage(ChatMessage message) async {
    await AudioFocusGuard.prepareForTts(
      cancelSttAction: () => _speechService.cancelListening(),
    );
    _avatarState = HalaAvatarState.speaking;
    _hudStatus = 'حلا تتحدث...';
    notifyListeners();

    await _ttsService.speak(message.text, dialect: message.dialect);

    _avatarState = HalaAvatarState.neutral;
    _hudStatus = 'Online • ${_geminiService.activeModelName}';
    notifyListeners();
  }

  /// Sets celebrating state for rewarding moments
  void celebrate() {
    _avatarState = HalaAvatarState.celebrating;
    notifyListeners();
    Timer(const Duration(seconds: 3), () {
      _avatarState = HalaAvatarState.neutral;
      notifyListeners();
    });
  }

  void clearConversation() {
    _initInitialGreeting();
  }
}
