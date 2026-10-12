import '../models/dialect.dart';
import '../models/mastery_topic.dart';

class MasteryRepository {
  // 1. Pronoun & Verb Conjugation Differences
  static const List<ConjugationItem> conjugations = [
    ConjugationItem(
      pronounEn: 'I (Present Continuous)',
      pronounAr: 'أنا',
      standardAr: 'أنا أكتب',
      egyptian: 'أنا بكتب',
      saudi: 'أنا أكتب / قاعد أكتب',
      emirati: 'أنا أكتب / جالس أكتب',
      note: 'Egyptian prefixes "بـ" for present continuous/habitual. Gulf uses "قاعد" or "جالس" + verb.',
    ),
    ConjugationItem(
      pronounEn: 'I (Future)',
      pronounAr: 'أنا',
      standardAr: 'سأذهب',
      egyptian: 'حروح / حَـسافر',
      saudi: 'بروح / بـسافر',
      emirati: 'بسير / بـسافر',
      note: 'Egyptian uses "حَـ" for future. Saudi uses "بـ". Emirati uses "بسير" specifically for going.',
    ),
    ConjugationItem(
      pronounEn: 'You (Male - What are you doing?)',
      pronounAr: 'أنتَ',
      standardAr: 'ماذا تفعل؟',
      egyptian: 'بتعمل إيه؟',
      saudi: 'وش قاعد تسوي؟',
      emirati: 'شو تسوي؟',
      note: 'Notice Egyptian "بتعمل" vs Saudi "تسوي" vs Emirati "تسوي".',
    ),
    ConjugationItem(
      pronounEn: 'You (Female - What are you doing?)',
      pronounAr: 'أنتِ',
      standardAr: 'ماذا تفعلين؟',
      egyptian: 'بتعملي إيه؟',
      saudi: 'وش تسوين؟',
      emirati: 'شو تسوين؟',
      note: 'Gulf preserves the nun "ين" in female verbs (تسوين), whereas Egyptian drops it (بتعملي).',
    ),
    ConjugationItem(
      pronounEn: 'We (We want)',
      pronounAr: 'نحن',
      standardAr: 'نريد',
      egyptian: 'عاوزين / عايزين',
      saudi: 'نبي / نبغى',
      emirati: 'نبا / نبغي',
      note: 'Egyptian uses active participle "عايزين", Gulf uses "نبي / نبا".',
    ),
    ConjugationItem(
      pronounEn: 'They (They saw)',
      pronounAr: 'هم',
      standardAr: 'رأوا',
      egyptian: 'شافوا',
      saudi: 'شافوا',
      emirati: 'شافوا / طالعوا',
      note: 'All dialects use "شاف", but Emirati also uniquely uses "طالع" for looking/watching.',
    ),
  ];

  // 2. Question Words Matrix
  static const List<QuestionWordItem> questionWords = [
    QuestionWordItem(
      english: 'Why?',
      standard: 'لماذا؟',
      egyptian: 'ليه؟',
      saudi: 'ليش؟',
      emirati: 'ليش؟',
      exampleSentence: 'ليش ما جيت أمس؟ / ليه ما جيتش إمبارح؟',
    ),
    QuestionWordItem(
      english: 'How?',
      standard: 'كيف؟',
      egyptian: 'إزاي؟',
      saudi: 'شلون؟ / كيف؟',
      emirati: 'كيف؟ / شلون؟',
      exampleSentence: 'إزاي الحال؟ / شلون الأمور معك؟',
    ),
    QuestionWordItem(
      english: 'Where?',
      standard: 'أين؟',
      egyptian: 'فين؟',
      saudi: 'وين؟',
      emirati: 'وين؟',
      exampleSentence: 'فين رايح؟ / وين تبي تروح؟',
    ),
    QuestionWordItem(
      english: 'When?',
      standard: 'متى؟',
      egyptian: 'إمتى؟',
      saudi: 'متى؟',
      emirati: 'متى؟',
      exampleSentence: 'إمتى حتيجي؟ / متى بتوصل؟',
    ),
    QuestionWordItem(
      english: 'What?',
      standard: 'ماذا؟',
      egyptian: 'إيه؟',
      saudi: 'وش؟ / إيش؟',
      emirati: 'شو؟',
      exampleSentence: 'إيه ده؟ / وش هذا؟ / شو ها؟',
    ),
    QuestionWordItem(
      english: 'Who?',
      standard: 'مَن؟',
      egyptian: 'مين؟',
      saudi: 'مين؟ / منو؟',
      emirati: 'منو؟',
      exampleSentence: 'مين على الباب؟ / منو هناك؟',
    ),
    QuestionWordItem(
      english: 'How much / How many?',
      standard: 'كم؟',
      egyptian: 'كام؟',
      saudi: 'كم؟',
      emirati: 'كم؟',
      exampleSentence: 'كام ده يا باشا؟ / كم سعره طال عمرك؟',
    ),
  ];

  // 3. Negation Systems
  static const List<NegationRuleItem> negations = [
    NegationRuleItem(
      conceptEn: 'Verbal Negation (Past & Present)',
      ruleExplanation: 'Egyptian wraps verbs in "ما...ش" sandwich. Saudi and Emirati use "ما" directly before the verb.',
      egyptianExample: 'ما عرفتش (I did not know) / ما بشربش (I do not drink)',
      saudiExample: 'ما عرفت / ما أشرب',
      emiratiExample: 'ما عرفت / ما أشرب',
    ),
    NegationRuleItem(
      conceptEn: 'Nominal & Adjectival Negation',
      ruleExplanation: 'Egyptian uses "مش". Saudi and Emirati use "مو".',
      egyptianExample: 'أنا مش تعبان / مش حلو كده',
      saudiExample: 'أنا مو تعبان / مو زين كذا',
      emiratiExample: 'أنا مو تعبان / مو حلو جيه',
    ),
    NegationRuleItem(
      conceptEn: 'There is NOT (Negating Existence)',
      ruleExplanation: 'Egyptian uses "مفيش". Saudi uses "ما فيه". Emirati uses "ما شي" or "ما فيه".',
      egyptianExample: 'مفيش سكر هنا',
      saudiExample: 'ما فيه سكر هنا',
      emiratiExample: 'ما شي شكر هني / ما فيه سكر',
    ),
    NegationRuleItem(
      conceptEn: 'Possessive Negation (I don\'t have)',
      ruleExplanation: 'Egyptian: "معاييش / عنديش". Saudi: "ما عندي / ما معي". Emirati: "ما عندي".',
      egyptianExample: 'ماعنديش وقت دلوقتي',
      saudiExample: 'ما عندي وقت الحين',
      emiratiExample: 'ما عندي وقت الحين',
    ),
  ];

  // 4. Gulf Honorifics & Courtesy Formulas
  static const List<HonorificItem> honorifics = [
    HonorificItem(
      phrase: 'طال عمرك',
      phonetic: 'Taal omrak',
      literalMeaning: 'May your lifespan be prolonged',
      culturalUse: 'Used constantly in Saudi and Emirati speech to show deep respect when addressing elders, clients, or officials.',
      primaryDialect: DialectType.saudi,
    ),
    HonorificItem(
      phrase: 'يا هلا والله ومسهلا',
      phonetic: 'Ya hala wallah wa mashala',
      literalMeaning: 'Oh welcome by God, and ease upon you',
      culturalUse: 'Warmest Saudi welcome formula, accompanied by putting a hand on the heart.',
      primaryDialect: DialectType.saudi,
    ),
    HonorificItem(
      phrase: 'مرحبا الساع',
      phonetic: 'Marhaba al-saa\'',
      literalMeaning: 'Welcome to this blessed hour',
      culturalUse: 'Signature Emirati greeting for welcoming an esteemed guest.',
      primaryDialect: DialectType.emirati,
    ),
    HonorificItem(
      phrase: 'فديتك / فديتج',
      phonetic: 'Fdeitak (male) / Fdeitij (female)',
      literalMeaning: 'May I be your ransom',
      culturalUse: 'Deeply endearing Emirati expression showing affection, helpfulness, and warm goodwill.',
      primaryDialect: DialectType.emirati,
    ),
    HonorificItem(
      phrase: 'كفو والله',
      phonetic: 'Kafu wallah',
      literalMeaning: 'Equal to the challenge / Worthy',
      culturalUse: 'High commendation across the Gulf for a person who handled something bravely or generously.',
      primaryDialect: DialectType.saudi,
    ),
    HonorificItem(
      phrase: 'على راسي',
      phonetic: 'Ala raasi',
      literalMeaning: 'Upon my head',
      culturalUse: 'Universal Arab gesture of willingness to fulfill any request with utmost honor.',
      primaryDialect: DialectType.egyptian,
    ),
    HonorificItem(
      phrase: 'تسلم ايدك / تسلم وتعيش',
      phonetic: 'Teslam eidak / Teslam wa t\'eesh',
      literalMeaning: 'May your hand be safe / May you stay safe and live long',
      culturalUse: 'Gratitude said when served food, coffee, or helped in any daily scenario.',
      primaryDialect: DialectType.egyptian,
    ),
    HonorificItem(
      phrase: 'ما تقصر والله',
      phonetic: 'Ma tgasser wallah',
      literalMeaning: 'You did not fall short in anything',
      culturalUse: 'The essential gratitude reply across Saudi Arabia and the Emirates.',
      primaryDialect: DialectType.saudi,
    ),
  ];
}
