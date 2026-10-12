import 'dart:async';

class AudioFocusGuard {
  /// Ensures TTS completely stops and audio pipeline settles before opening the microphone
  static Future<void> prepareForStt({
    required Future<void> Function() stopTtsAction,
  }) async {
    try {
      await stopTtsAction();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 120));
  }

  /// Ensures Speech recognition is canceled before TTS begins speaking
  static Future<void> prepareForTts({
    required Future<void> Function() cancelSttAction,
  }) async {
    try {
      await cancelSttAction();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 80));
  }
}
