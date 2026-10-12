import 'package:flutter_test/flutter_test.dart';
import 'package:halaaiarabic/core/utils/arabic_similarity.dart';
import 'package:halaaiarabic/data/models/dialect.dart';

void main() {
  test('Arabic dialect models and similarity scoring test', () {
    expect(DialectType.egyptian.shortArabicName, 'مصري');
    expect(DialectType.saudi.shortArabicName, 'سعودي');
    expect(DialectType.emirati.shortArabicName, 'إماراتي');

    final similarity = ArabicSimilarity.calculateSimilarity('يا هلا والله', 'يا هلا والله');
    expect(similarity, 1.0);

    final normalized = ArabicSimilarity.normalizeArabic('أَهْلاً وَسَهْلاً!');
    expect(normalized.contains('اهلا'), true);
  });
}
