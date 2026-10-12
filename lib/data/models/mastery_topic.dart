import 'dialect.dart';

class ConjugationItem {
  final String pronounEn;
  final String pronounAr;
  final String standardAr;
  final String egyptian;
  final String saudi;
  final String emirati;
  final String note;

  const ConjugationItem({
    required this.pronounEn,
    required this.pronounAr,
    required this.standardAr,
    required this.egyptian,
    required this.saudi,
    required this.emirati,
    required this.note,
  });

  String getFor(DialectType dialect) {
    switch (dialect) {
      case DialectType.egyptian:
        return egyptian;
      case DialectType.saudi:
        return saudi;
      case DialectType.emirati:
        return emirati;
    }
  }
}

class QuestionWordItem {
  final String english;
  final String standard;
  final String egyptian;
  final String saudi;
  final String emirati;
  final String exampleSentence;

  const QuestionWordItem({
    required this.english,
    required this.standard,
    required this.egyptian,
    required this.saudi,
    required this.emirati,
    required this.exampleSentence,
  });
}

class NegationRuleItem {
  final String conceptEn;
  final String ruleExplanation;
  final String egyptianExample;
  final String saudiExample;
  final String emiratiExample;

  const NegationRuleItem({
    required this.conceptEn,
    required this.ruleExplanation,
    required this.egyptianExample,
    required this.saudiExample,
    required this.emiratiExample,
  });
}

class HonorificItem {
  final String phrase;
  final String phonetic;
  final String literalMeaning;
  final String culturalUse;
  final DialectType primaryDialect;

  const HonorificItem({
    required this.phrase,
    required this.phonetic,
    required this.literalMeaning,
    required this.culturalUse,
    required this.primaryDialect,
  });
}
