import 'dart:math';

class ArabicSimilarity {
  /// Strips diacritics and unifies Arabic letter variants for forgiving speech recognition matching
  static String normalizeArabic(String text) {
    if (text.isEmpty) return '';

    var clean = text.trim().toLowerCase();

    // Remove tashkeel / harakat (diacritics)
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u0640]');
    clean = clean.replaceAll(diacritics, '');

    // Normalize Alefs
    clean = clean.replaceAll(RegExp(r'[إأآٱ]'), 'ا');

    // Normalize Teh Marbuta and Heh
    clean = clean.replaceAll('ة', 'ه');

    // Normalize Alef Maqsura and Yeh
    clean = clean.replaceAll('ى', 'ي');

    // Remove punctuation
    clean = clean.replaceAll(RegExp(r'[\?؟!.,:;\-—_()\[\]{}"' r"']"), ' ');

    // Normalize multiple spaces
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();

    return clean;
  }

  /// Calculates Levenshtein similarity ratio between 0.0 and 1.0
  static double calculateSimilarity(String spoken, String target) {
    final normSpoken = normalizeArabic(spoken);
    final normTarget = normalizeArabic(target);

    if (normSpoken.isEmpty && normTarget.isEmpty) return 1.0;
    if (normSpoken.isEmpty || normTarget.isEmpty) return 0.0;
    if (normSpoken == normTarget) return 1.0;

    // Direct containment bonus for longer phrases
    if (normSpoken.contains(normTarget) || normTarget.contains(normSpoken)) {
      final ratio = min(normSpoken.length, normTarget.length) /
          max(normSpoken.length, normTarget.length);
      return max(0.85, ratio);
    }

    // Levenshtein distance
    final distance = _levenshteinDistance(normSpoken, normTarget);
    final maxLength = max(normSpoken.length, normTarget.length);
    final score = 1.0 - (distance / maxLength);
    return max(0.0, min(1.0, score));
  }

  static int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;

    List<int> previousRow = List<int>.generate(n + 1, (i) => i);
    List<int> currentRow = List<int>.filled(n + 1, 0);

    for (int i = 0; i < m; i++) {
      currentRow[0] = i + 1;
      for (int j = 0; j < n; j++) {
        final cost = (s1[i] == s2[j]) ? 0 : 1;
        currentRow[j + 1] = min(
          currentRow[j] + 1, // insertion
          min(
            previousRow[j + 1] + 1, // deletion
            previousRow[j] + cost, // substitution
          ),
        );
      }
      for (int j = 0; j <= n; j++) {
        previousRow[j] = currentRow[j];
      }
    }

    return previousRow[n];
  }
}
