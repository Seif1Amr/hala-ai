import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/dialect.dart';

class ArabicTtsService extends ChangeNotifier {
  static const String _prefKeyGeminiKey = 'hala_gemini_api_key';
  static const String _defaultApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  String? _loadingText;
  String? get loadingText => _loadingText;
  bool get isLoading => _loadingText != null;

  String? _speakingText;
  String? get speakingText => _speakingText;

  bool isTextLoading(String text) => _loadingText != null && _loadingText == text.trim();
  bool isTextSpeaking(String text) => _isSpeaking && _speakingText == text.trim();

  final double _volume = 1.0;
  final double _pitch = 1.05; // Slightly warmer female pitch
  final double _rate = 0.48; // Measured rate for clear dialect learning

  StreamSubscription? _playerCompleteSub;
  StreamSubscription? _playerStateSub;
  Completer<void>? _speakCompleter;

  void _finishSpeaking() {
    _loadingText = null;
    _speakingText = null;
    _isSpeaking = false;
    if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
      _speakCompleter!.complete();
    }
    notifyListeners();
  }

  ArabicTtsService() {
    _initTts();
    _initAudioPlayer();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);

      _flutterTts.setStartHandler(() {
        _loadingText = null;
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _finishSpeaking();
      });

      _flutterTts.setCancelHandler(() {
        _finishSpeaking();
      });

      _flutterTts.setErrorHandler((dynamic msg) {
        _finishSpeaking();
        debugPrint('[ArabicTts] Error: $msg');
      });
    } catch (e) {
      debugPrint('[ArabicTts] Init exception: $e');
    }
  }

  void _initAudioPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) async {
      try {
        await _audioPlayer.stop();
      } catch (_) {}
      _finishSpeaking();
    });

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (!_isSpeaking) {
          _loadingText = null;
          _isSpeaking = true;
          notifyListeners();
        }
      } else if (state == PlayerState.completed || state == PlayerState.stopped) {
        _finishSpeaking();
      }
    });
  }

  /// Speaks the given text. If a Google AI Studio API key is configured,
  /// it generates ultra-realistic native dialect speech via Gemini Audio.
  /// Otherwise, it falls back to device TTS.
  Future<void> speak(String text, {required DialectType dialect}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      await stop();

      _loadingText = cleanText;
      _speakingText = null;
      notifyListeners();

      // Check for Google AI Studio API key (custom or default)
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString(_prefKeyGeminiKey)?.trim();
      final apiKey = (userKey != null && userKey.isNotEmpty) ? userKey : _defaultApiKey;

      if (apiKey.isNotEmpty) {
        final success = await _speakWithGoogleAiStudio(cleanText, dialect: dialect, apiKey: apiKey);
        if (success) return;
      }

      // Fallback to on-device TTS
      await _speakWithDeviceTts(cleanText, dialect: dialect);
    } catch (e) {
      _finishSpeaking();
      debugPrint('[ArabicTts] Speak error: $e');
    }
  }

  /// Generates authentic, human-sounding dialect speech via Google AI Studio Gemini API
  Future<bool> _speakWithGoogleAiStudio(
    String text, {
    required DialectType dialect,
    required String apiKey,
  }) async {
    final models = [
      'gemini-3.8-flash-tts',
      'gemini-3.8-flash-lite-tts',
      'gemini-2.5-flash-preview-tts',
    ];

    final dialectName = dialect.englishName;

    for (final model in models) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        // CRITICAL FIX: Gemini 3.8 Flash TTS treats text strictly as a verbatim transcript!
        // Never put instructions inside 'text', as the model will read them out loud.
        // Turn-level delivery belongs inside 'speech_metadata.style'.
        final body = jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': text,
                  'speech_metadata': {
                    'style': 'warm native female tutor, authentic colloquial $dialectName pronunciation',
                  },
                }
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'speechConfig': {
              'voiceConfig': {
                'voice': 'Kore',
              }
            }
          }
        });

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final inlineData = parts[0]['inlineData'];
              if (inlineData != null) {
                final base64Audio = inlineData['data'] as String;
                final mimeType = (inlineData['mimeType'] as String? ?? '').toLowerCase();

                Uint8List audioBytes = base64Decode(base64Audio);

                // If headerless PCM (starts without 'RIFF'), wrap with standard WAV header
                if (mimeType.contains('pcm') ||
                    audioBytes.length < 4 ||
                    String.fromCharCodes(audioBytes.sublist(0, 4)) != 'RIFF') {
                  audioBytes = _addWavHeader(audioBytes, 24000, 1, 16);
                }

                _speakCompleter = Completer<void>();
                _loadingText = null;
                _speakingText = text;
                _isSpeaking = true;
                notifyListeners();

                // Explicitly stop previous sound and force single play with in-memory BytesSource
                await _audioPlayer.stop();
                await _audioPlayer.setReleaseMode(ReleaseMode.stop);
                await _audioPlayer.play(BytesSource(audioBytes));

                try {
                  await _speakCompleter!.future.timeout(const Duration(seconds: 25));
                } catch (_) {
                  await stop();
                }
                return true;
              }
            }
          }
        } else {
          debugPrint('[GoogleAiStudioTts] HTTP ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('[GoogleAiStudioTts] Error with $model: $e');
      }
    }

    return false;
  }

  /// Adds a standard 44-byte RIFF WAV header to raw 16-bit PCM audio bytes
  Uint8List _addWavHeader(Uint8List pcmBytes, int sampleRate, int channels, int bitsPerSample) {
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);
    final totalDataLen = pcmBytes.length;
    final totalAudioLen = totalDataLen + 36;

    final header = Uint8List(44);
    final byteData = ByteData.view(header.buffer);

    // RIFF chunk
    header.setRange(0, 4, 'RIFF'.codeUnits);
    byteData.setUint32(4, totalAudioLen, Endian.little);
    header.setRange(8, 12, 'WAVE'.codeUnits);

    // fmt subchunk
    header.setRange(12, 16, 'fmt '.codeUnits);
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, channels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    header.setRange(36, 40, 'data'.codeUnits);
    byteData.setUint32(40, totalDataLen, Endian.little);

    final wavBytes = Uint8List(44 + totalDataLen);
    wavBytes.setRange(0, 44, header);
    wavBytes.setRange(44, wavBytes.length, pcmBytes);
    return wavBytes;
  }

  /// Fallback device TTS
  Future<void> _speakWithDeviceTts(String text, {required DialectType dialect}) async {
    final targetLocale = dialect.localeCode;
    await _flutterTts.setLanguage(targetLocale);

    _speakCompleter = Completer<void>();
    _loadingText = null;
    _speakingText = text;
    _isSpeaking = true;
    notifyListeners();

    await _flutterTts.speak(text);
    try {
      await _speakCompleter!.future.timeout(const Duration(seconds: 25));
    } catch (_) {
      _finishSpeaking();
    }
  }

  /// Stops all TTS and AudioPlayer playback immediately
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('[ArabicTts] Stop error: $e');
    } finally {
      _finishSpeaking();
    }
  }

  @override
  void dispose() {
    _playerCompleteSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
