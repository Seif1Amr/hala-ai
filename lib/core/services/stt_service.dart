import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../data/models/dialect.dart';

class ArabicSpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _currentWords = '';
  String get currentWords => _currentWords;

  String? _lastError;
  String? get lastError => _lastError;

  ArabicSpeechService() {
    _initialize();
  }

  Future<bool> _initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (val) {
          debugPrint('[ArabicSTT] Error: ${val.errorMsg}');
          _lastError = val.errorMsg;
          _isListening = false;
          notifyListeners();
        },
        onStatus: (val) {
          debugPrint('[ArabicSTT] Status: $val');
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
      notifyListeners();
      return _isInitialized;
    } catch (e) {
      debugPrint('[ArabicSTT] Initialization exception: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Begins listening in the target Arabic dialect locale
  Future<bool> startListening({
    required DialectType dialect,
    required Function(String words, bool isFinal) onResultCallback,
  }) async {
    final ready = await _initialize();
    if (!ready) return false;

    _currentWords = '';
    _lastError = null;

    final targetLocaleId = dialect.speechLocale;

    try {
      await _speech.listen(
        onResult: (result) {
          _currentWords = result.recognizedWords;
          notifyListeners();
          onResultCallback(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: targetLocaleId,
          cancelOnError: true,
          partialResults: true,
        ),
      );

      _isListening = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ArabicSTT] Listen exception: $e');
      _isListening = false;
      notifyListeners();
      return false;
    }
  }

  /// CANCEL listening: flushes the OS pipeline and suppresses trailing callbacks (RULE 1)
  Future<void> cancelListening() async {
    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
    } catch (e) {
      debugPrint('[ArabicSTT] Cancel error: $e');
    } finally {
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stop listening (normal stop)
  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('[ArabicSTT] Stop error: $e');
    } finally {
      _isListening = false;
      notifyListeners();
    }
  }

  void clearWords() {
    _currentWords = '';
    notifyListeners();
  }
}
