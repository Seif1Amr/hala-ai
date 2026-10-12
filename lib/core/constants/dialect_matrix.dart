import '../../data/models/dialect.dart';

class DialectMatrixItem {
  final String concept;
  final String conceptEn;
  final String category;
  final String egyptian;
  final String egyptianPhonetic;
  final String saudi;
  final String saudiPhonetic;
  final String emirati;
  final String emiratiPhonetic;
  final String culturalNote;

  const DialectMatrixItem({
    required this.concept,
    required this.conceptEn,
    required this.category,
    required this.egyptian,
    required this.egyptianPhonetic,
    required this.saudi,
    required this.saudiPhonetic,
    required this.emirati,
    required this.emiratiPhonetic,
    required this.culturalNote,
  });

  String getPhraseFor(DialectType dialect) {
    switch (dialect) {
      case DialectType.egyptian:
        return egyptian;
      case DialectType.saudi:
        return saudi;
      case DialectType.emirati:
        return emirati;
    }
  }

  String getPhoneticFor(DialectType dialect) {
    switch (dialect) {
      case DialectType.egyptian:
        return egyptianPhonetic;
      case DialectType.saudi:
        return saudiPhonetic;
      case DialectType.emirati:
        return emiratiPhonetic;
    }
  }
}

class DialectMatrix {
  static const List<DialectMatrixItem> items = [
    DialectMatrixItem(
      concept: 'كيف الحال؟',
      conceptEn: 'How are you?',
      category: 'Greetings',
      egyptian: 'إزيك؟ عامل إيه؟',
      egyptianPhonetic: 'Izzayak? Aamel eh?',
      saudi: 'كيف حالك؟ وش مسوي؟',
      saudiPhonetic: 'Keif halak? Wesh msawi?',
      emirati: 'شحالك؟ شخبارك؟',
      emiratiPhonetic: 'Sh-halak? Sh-akhbarak?',
      culturalNote: 'Emirati often softens "K" sounds, and "شحالك" is the universal Gulf hello.',
    ),
    DialectMatrixItem(
      concept: 'ماذا تريد؟',
      conceptEn: 'What do you want?',
      category: 'Desires',
      egyptian: 'عاوز إيه؟ / عايزة إيه؟',
      egyptianPhonetic: 'Aawez eh? / Aayza eh?',
      saudi: 'وش تبغى؟ / وش تبي؟',
      saudiPhonetic: 'Wesh tebgha? / Wesh tebi?',
      emirati: 'شو تبغي؟ / شو تبا؟',
      emiratiPhonetic: 'Sho tebghi? / Sho teba?',
      culturalNote: 'Egyptian "عاوز" comes from standard root "عوز", while Gulf prefers "تبي / تبا".',
    ),
    DialectMatrixItem(
      concept: 'كثيراً / جداً',
      conceptEn: 'A lot / Very much',
      category: 'Adverbs',
      egyptian: 'أوي / كتير',
      egyptianPhonetic: 'Awi / Kteer',
      saudi: 'مرة / بالحيل',
      saudiPhonetic: 'Marrah / Bil-heel',
      emirati: 'وايد / حيل',
      emiratiPhonetic: 'Waayed / Heel',
      culturalNote: '"وايد" is the signature Emirati hallmark; "مرة" dominates Najdi and Hijazi Saudi.',
    ),
    DialectMatrixItem(
      concept: 'الآن',
      conceptEn: 'Now',
      category: 'Time',
      egyptian: 'دلوقتي',
      egyptianPhonetic: 'Delwa\'ti',
      saudi: 'الحين',
      saudiPhonetic: 'Al-heen',
      emirati: 'الحين',
      emiratiPhonetic: 'Al-heen',
      culturalNote: 'Egyptian "دلوقتي" is a contraction of "ده الوقت" (this time).',
    ),
    DialectMatrixItem(
      concept: 'انظر / انظري',
      conceptEn: 'Look / See',
      category: 'Imperatives',
      egyptian: 'بص / شوفي',
      egyptianPhonetic: 'Buss / Shoofi',
      saudi: 'شف / شوف',
      saudiPhonetic: 'Shif / Shoof',
      emirati: 'طالع / شوف',
      emiratiPhonetic: 'Taali\' / Shoof',
      culturalNote: '"طالع" in Emirati means to look at something intently.',
    ),
    DialectMatrixItem(
      concept: 'جيد / ممتاز',
      conceptEn: 'Good / Nice / Fine',
      category: 'Qualifiers',
      egyptian: 'كويس / تمام',
      egyptianPhonetic: 'Kowayyes / Tamaam',
      saudi: 'زين / طيب',
      saudiPhonetic: 'Zain / Tayyeb',
      emirati: 'زين / كفو',
      emiratiPhonetic: 'Zain / Kafu',
      culturalNote: '"كفو" is high praise throughout the Emirates denoting excellence and reliability.',
    ),
    DialectMatrixItem(
      concept: 'لماذا؟',
      conceptEn: 'Why?',
      category: 'Questions',
      egyptian: 'ليه؟',
      egyptianPhonetic: 'Leih?',
      saudi: 'ليش؟',
      saudiPhonetic: 'Leish?',
      emirati: 'ليش؟',
      emiratiPhonetic: 'Leish?',
      culturalNote: 'Egyptian softens into "ليه", whereas Gulf uses the energetic "ليش".',
    ),
    DialectMatrixItem(
      concept: 'أين؟',
      conceptEn: 'Where?',
      category: 'Questions',
      egyptian: 'فين؟',
      egyptianPhonetic: 'Fein?',
      saudi: 'وين؟',
      saudiPhonetic: 'Wein?',
      emirati: 'وين؟',
      emiratiPhonetic: 'Wein?',
      culturalNote: 'Egyptian substitutes W with F ("فين" from في أين).',
    ),
    DialectMatrixItem(
      concept: 'كيف؟',
      conceptEn: 'How?',
      category: 'Questions',
      egyptian: 'إزاي؟',
      egyptianPhonetic: 'Izzay?',
      saudi: 'شلون؟ / كيف؟',
      saudiPhonetic: 'Shlawn? / Keif?',
      emirati: 'كيف؟ / شلون؟',
      emiratiPhonetic: 'Keif? / Shlawn?',
      culturalNote: '"شلون" is a compound of "أي شيء يكون لونه" (what is its color/state).',
    ),
    DialectMatrixItem(
      concept: 'شكراً جزيلاً',
      conceptEn: 'Thank you very much / You\'re generous',
      category: 'Hospitality',
      egyptian: 'تسلم ايدك / يا باشا ألف شكر',
      egyptianPhonetic: 'Teslam eidak / Ya basha alf shukr',
      saudi: 'طال عمرك / ما تقصر والله',
      saudiPhonetic: 'Taal omrak / Ma tgasser wallah',
      emirati: 'مرحبا الساع / ما تقصر فديتك',
      emiratiPhonetic: 'Marhaba al-saa\' / Ma tgasser fdeitak',
      culturalNote: '"ما تقصر" literally means "You did not fall short" - the premier gratitude phrase.',
    ),
    DialectMatrixItem(
      concept: 'لا أعلم',
      conceptEn: 'I don\'t know',
      category: 'Negation',
      egyptian: 'معرفش / مش عارف',
      egyptianPhonetic: 'Ma\'arafsh / Mosh aaref',
      saudi: 'ما أدري / ما أعرف',
      saudiPhonetic: 'Ma adri / Ma aaref',
      emirati: 'ما أدري / ما عرفت',
      emiratiPhonetic: 'Ma adri / Ma araft',
      culturalNote: 'Egyptian wraps verbs with "ما...ش", while Gulf uses particle "ما" or "مو".',
    ),
    DialectMatrixItem(
      concept: 'أنا ذاهب',
      conceptEn: 'I am going',
      category: 'Verbs',
      egyptian: 'أنا رايح / حروح',
      egyptianPhonetic: 'Ana raayeha / Harooh',
      saudi: 'بروح / ماشي',
      saudiPhonetic: 'Barooh / Maashi',
      emirati: 'بسير / رايح',
      emiratiPhonetic: 'Baseer / Raayeh',
      culturalNote: '"بسير" (from سير - walking/moving) is typical Emirati for "I\'m going".',
    ),
    DialectMatrixItem(
      concept: 'أرسل لي',
      conceptEn: 'Send to me',
      category: 'Verbs',
      egyptian: 'ابعتلي',
      egyptianPhonetic: 'Eb\'atli',
      saudi: 'طرّشلي / أرسل لي',
      saudiPhonetic: 'Tarresh-li / Arsel-li',
      emirati: 'طرّشلي',
      emiratiPhonetic: 'Tarresh-li / Tarishli',
      culturalNote: '"طرّشلي" is the beloved authentic Gulf and Emirati term for "send me", contrasted with Egyptian "ابعتلي".',
    ),
    DialectMatrixItem(
      concept: 'انتظرني',
      conceptEn: 'Wait for me',
      category: 'Verbs',
      egyptian: 'استناني / لحظة',
      egyptianPhonetic: 'Estannani / Lahza',
      saudi: 'اصبر لي / استناني',
      saudiPhonetic: 'Isbir li / Estannani',
      emirati: 'ترياني / اصبر شوي',
      emiratiPhonetic: 'Trayyani / Isbir shway',
      culturalNote: '"ترياني" (Trayyani) is quintessential Emirati for "wait for me".',
    ),
  ];
}
