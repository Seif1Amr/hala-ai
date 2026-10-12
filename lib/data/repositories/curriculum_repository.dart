import 'package:shared_preferences/shared_preferences.dart';
import '../models/dialect.dart';
import '../models/lesson_model.dart';

class CurriculumRepository {
  static const String _keyCompletedLevels = 'hala_completed_levels_set';
  static const String _keyLevelStarsPrefix = 'hala_level_stars_';

  List<CurriculumLevel>? _cachedLevels;

  /// Retrieves all 600 levels across 6 tiers
  Future<List<CurriculumLevel>> getLevels(DialectType dialect) async {
    if (_cachedLevels == null) {
      _cachedLevels = _generateAll600Levels();
      await _loadProgressFromPrefs(_cachedLevels!);
    }
    return _cachedLevels!;
  }

  Future<void> _loadProgressFromPrefs(List<CurriculumLevel> levels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedStrings = prefs.getStringList(_keyCompletedLevels) ?? [];
      final completedSet = completedStrings.map((e) => int.tryParse(e) ?? 0).toSet();

      for (var level in levels) {
        if (completedSet.contains(level.levelNumber)) {
          level.isCompleted = true;
          level.stars = prefs.getInt('$_keyLevelStarsPrefix${level.levelNumber}') ?? 3;
        }
      }
    } catch (_) {}
  }

  Future<void> saveLevelCompletion(int levelNumber, int stars) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList(_keyCompletedLevels) ?? [];
      if (!completedList.contains(levelNumber.toString())) {
        completedList.add(levelNumber.toString());
        await prefs.setStringList(_keyCompletedLevels, completedList);
      }
      await prefs.setInt('$_keyLevelStarsPrefix$levelNumber', stars);

      if (_cachedLevels != null) {
        final level = _cachedLevels!.firstWhere(
          (l) => l.levelNumber == levelNumber,
          orElse: () => _cachedLevels!.first,
        );
        level.isCompleted = true;
        level.stars = stars;
      }
    } catch (_) {}
  }

  /// Generates the full 600 levels organized across 6 distinct tiers
  List<CurriculumLevel> _generateAll600Levels() {
    final List<CurriculumLevel> list = [];

    // Tier 1: Foundations (Levels 1 - 100)
    for (int i = 1; i <= 100; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 1,
        tierTitle: 'Foundations',
        title: _getTier1Title(i),
        titleAr: _getTier1TitleAr(i),
        objective: 'Warm greetings, hospitality, numbers, and basic courtesy.',
        exercises: _generateTier1Exercises(i),
      ));
    }

    // Tier 2: Everyday Life (Levels 101 - 200)
    for (int i = 101; i <= 200; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 2,
        tierTitle: 'Everyday Life',
        title: _getTier2Title(i),
        titleAr: _getTier2TitleAr(i),
        objective: 'Taxis, directions, souks, bargaining, and restaurant dining.',
        exercises: _generateTier2Exercises(i),
      ));
    }

    // Tier 3: Social & Family (Levels 201 - 300)
    for (int i = 201; i <= 300; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 3,
        tierTitle: 'Social & Family',
        title: _getTier3Title(i),
        titleAr: _getTier3TitleAr(i),
        objective: 'Arab social etiquette, congrats, condolences, emotions.',
        exercises: _generateTier3Exercises(i),
      ));
    }

    // Tier 4: Work & Professional (Levels 301 - 400)
    for (int i = 301; i <= 400; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 4,
        tierTitle: 'Work & Professional',
        title: _getTier4Title(i),
        titleAr: _getTier4TitleAr(i),
        objective: 'Gulf business meetings, negotiations, formal invitations.',
        exercises: _generateTier4Exercises(i),
      ));
    }

    // Tier 5: Nuances & Idioms (Levels 401 - 500)
    for (int i = 401; i <= 500; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 5,
        tierTitle: 'Nuances & Idioms',
        title: _getTier5Title(i),
        titleAr: _getTier5TitleAr(i),
        objective: 'Famous proverbs, metaphors, humor, subtle dialect contrasts.',
        exercises: _generateTier5Exercises(i),
      ));
    }

    // Tier 6: Native Fluency (Levels 501 - 600)
    for (int i = 501; i <= 600; i++) {
      list.add(_buildLevel(
        levelNum: i,
        tierNum: 6,
        tierTitle: 'Native Fluency',
        title: _getTier6Title(i),
        titleAr: _getTier6TitleAr(i),
        objective: 'Fast native dialogues, media commentary, idiomatic mastery.',
        exercises: _generateTier6Exercises(i),
      ));
    }

    return list;
  }

  CurriculumLevel _buildLevel({
    required int levelNum,
    required int tierNum,
    required String tierTitle,
    required String title,
    required String titleAr,
    required String objective,
    required List<ExerciseItem> exercises,
  }) {
    return CurriculumLevel(
      levelNumber: levelNum,
      tierNumber: tierNum,
      tierTitle: tierTitle,
      title: title,
      titleAr: titleAr,
      objective: objective,
      exercises: exercises,
    );
  }

  // --- Title Generators ---
  String _getTier1Title(int i) {
    final sub = (i - 1) % 10;
    const titles = [
      'Warm Welcome & First Greetings',
      'Asking "How Are You?"',
      'Hospitality & Welcoming Formulas',
      'Arabic Coffee (Gahwa) Etiquette',
      'Numbers & Polite Counting',
      'Expressing Gratitude & Praise',
      'Introductions & Homeland',
      'Pleased to Meet You Expressions',
      'Saying Goodbye with Warmth',
      'Tier 1 Mastery Review',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier1TitleAr(int i) {
    final sub = (i - 1) % 10;
    const titles = [
      'الترحيب والتحية الأولى',
      'السؤال عن الحال والأحوال',
      'أصول الضيافة والاستقبال',
      'آداب فنجان القهوة',
      'الأرقام والعد بلباقة',
      'عبارات الشكر والامتنان',
      'التعارف والأصل والبلد',
      'التشرف بالمعرفة',
      'الوداع بعبارات المحبة',
      'مراجعة شاملة للمستوى الأول',
    ];
    return titles[sub];
  }

  String _getTier2Title(int i) {
    final sub = (i - 101) % 10;
    const titles = [
      'Catching a Taxi & Giving Directions',
      'Walking Through the Souk',
      'Bargaining & Asking the Price',
      'Ordering at the Street Eatery',
      'Asking for the Bill & Tipping',
      'Shopping for Spices & Oud',
      'ATM & Currency Exchange',
      'Asking for Help & Navigation',
      'Pharmacy & Emergency Needs',
      'Tier 2 Everyday Fluency Check',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier2TitleAr(int i) {
    final sub = (i - 101) % 10;
    const titles = [
      'ركوب التاكسي وتحديد الاتجاهات',
      'جولة في السوق الشعبي',
      'المفاصلة والسؤال عن السعر',
      'الطلب في المطعم والمقهى',
      'طلب الحساب ودفع الفاتورة',
      'شراء العود والبهارات الأصيلة',
      'الصرافة والعملات البنكية',
      'طلب المساعدة في الطريق',
      'الصيدلية والاحتياجات اليومية',
      'اختبار طلاقة الحياة اليومية',
    ];
    return titles[sub];
  }

  String _getTier3Title(int i) {
    final sub = (i - 201) % 10;
    const titles = [
      'Arab Majlis & Family Etiquette',
      'Complimenting the Host',
      'Eid & Holiday Greetings',
      'Weddings & Celebrations (Mabrook)',
      'Condolences & Sympathy Words',
      'Apologizing with Sincerity',
      'Talking About Children & Family',
      'Expressing Admiration & "Masha\'Allah"',
      'Hospitality Refusal Tact',
      'Tier 3 Social Fluency Milestone',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier3TitleAr(int i) {
    final sub = (i - 201) % 10;
    const titles = [
      'آداب المجلس والعائلة',
      'مجاملة صاحب البيت والمضيف',
      'تهاني الأعياد والمناسبات',
      'الأفراح والتهنئة بالزواج',
      'واجب العزاء والمواساة',
      'الاعتذار الصادق واللباقة',
      'الحديث عن الأسرة والأبناء',
      'الإعجاب وذكر ما شاء الله',
      'الاعتذار عن الإحراج بلطف',
      'محطة التميز الاجتماعي',
    ];
    return titles[sub];
  }

  String _getTier4Title(int i) {
    final sub = (i - 301) % 10;
    const titles = [
      'Gulf Corporate Greetings',
      'Setting Up a Business Meeting',
      'Polite Commercial Inquiries',
      'Negotiating Deadlines & Deals',
      'Professional Phone Manners',
      'Formal Arabic Email Sign-offs',
      'Presenting Your Proposal',
      'Handling Disagreements Politely',
      'Networking at Gulf Conferences',
      'Tier 4 Professional Certification',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier4TitleAr(int i) {
    final sub = (i - 301) % 10;
    const titles = [
      'تحيات الأعمال في الخليج',
      'تحديد مواعيد الاجتماعات',
      'الاستفسارات التجارية الرسمية',
      'التفاوض على العقود والصفقات',
      'آداب المكالمات المهنية',
      'خواتيم المراسلات الرسمية',
      'تقديم العروض الاستثمارية',
      'إبداء الملاحظات بلباقة',
      'بناء العلاقات في المؤتمرات',
      'شهادة الطلاقة المهنية',
    ];
    return titles[sub];
  }

  String _getTier5Title(int i) {
    final sub = (i - 401) % 10;
    const titles = [
      'Proverbs on Patience & Time',
      'Proverbs on Friendship & Loyalty',
      'Gulf Desert Metaphors',
      'Egyptian Cinematic Humor',
      'Intonation & Irony in Arabic',
      'Double Entendres & Puns',
      'Expressing Deep Wonder',
      'Dialect False Friends (Watch Out)',
      'Levantine vs Gulf Nuances',
      'Tier 5 Idiomatic Mastery Exam',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier5TitleAr(int i) {
    final sub = (i - 401) % 10;
    const titles = [
      'أمثال شعبية في الصبر والوقت',
      'أمثال الصداقة والوفاء',
      'استعارات بيئة الصحراء والخليج',
      'خفة الظل والقفشات المصرية',
      'نبرة الصوت والمعاني الضمنية',
      'التورية والألغاز الكلامية',
      'التعبير عن الدهشة البالغة',
      'كلمات متشابهة بمعانٍ مختلفة',
      'فروق دقيقة بين اللهجات',
      'اختبار التعابير البلاغية',
    ];
    return titles[sub];
  }

  String _getTier6Title(int i) {
    final sub = (i - 501) % 10;
    const titles = [
      'Fast Street Colloquial Flow',
      'Debating Current Affairs',
      'Art & Arabic Poetry Nuance',
      'Rapid Retorts & Comebacks',
      'Storytelling with Emotion',
      'Multi-Dialect Shifting',
      'Deep Cultural Philosophical Chats',
      'Mastering Gulf Diminutives',
      'Advanced Dialect Improvisation',
      'Level 600 Grand Master Graduation',
    ];
    return 'Level $i: ${titles[sub]}';
  }

  String _getTier6TitleAr(int i) {
    final sub = (i - 501) % 10;
    const titles = [
      'سرعة الحوار في الشارع',
      'نقاش القضايا العامة',
      'تذوق الشعر والفنون',
      'سرعة البديهة والردود الذكية',
      'سرد الحكايات والقصص بحماس',
      'التنقل السلس بين اللهجات',
      'حوارات فكرية وثقافية عميقة',
      'صيغ التصغير والتحبب الخليجية',
      'الارتجال الصوتي المتقدم',
      'مستوى 600: التخرج والتتويج',
    ];
    return titles[sub];
  }

  // --- Dynamic Exercise Generators ---
  List<ExerciseItem> _generateTier1Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'يا هلا والله! نورتنا اليوم',
        phoneticGuide: 'Ya hala wallah! Nawwartana al-yowm',
        englishMeaning: 'A warm welcome! You have brought light to our day',
        culturalTip: 'Universally used across the Gulf and Egypt to honor arriving guests.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'تسلم والله، ما تقصر طال عمرك',
        phoneticGuide: 'Teslam wallah, ma tgasser taal omrak',
        englishMeaning: 'Bless you, you did more than enough, may your life be long',
        culturalTip: 'The ultimate respectful gratitude response in Saudi and Emirati.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'الحين',
        phoneticGuide: 'Al-heen',
        englishMeaning: 'Now',
        question: 'What is the Egyptian equivalent of the Gulf word "الحين" (Now)?',
        options: ['دلوقتي', 'بعدين', 'إمبارح', 'بكرة'],
        correctOptionIndex: 0,
        culturalTip: 'Egyptian uses "دلوقتي" (contraction of ده الوقت), while Gulf uses "الحين".',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'أهلاً وسهلاً، تفضل بالراحة',
        phoneticGuide: 'Ahlan wa sahlan, tfaddal bil-raaha',
        englishMeaning: 'Welcome, please make yourself comfortable',
        culturalTip: 'Warm Arab hospitality invite when entering any home or majlis.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'وايد',
        phoneticGuide: 'Waayed',
        englishMeaning: 'A lot / Very',
        question: 'In Emirati Arabic, how do you say "A lot / Very much"?',
        options: ['وايد', 'قليل', 'شوي', 'تمام'],
        correctOptionIndex: 0,
        culturalTip: '"وايد" is the iconic hallmark of the Emirati dialect.',
      ),
    ];
  }

  List<ExerciseItem> _generateTier2Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'على يدك اليمين بعد الإشارة، لو سمحت',
        phoneticGuide: 'Ala yaddak al-yameen ba\'d al-ishara, law samaht',
        englishMeaning: 'On your right side after the traffic light, please',
        culturalTip: 'Essential taxi and navigation phrase.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'كم آخر سعر تقدر تنزل فيه؟',
        phoneticGuide: 'Kam aakher se\'er tegdar tanzel feeh?',
        englishMeaning: 'What is the absolute final price you can offer?',
        culturalTip: 'Polite souk bargaining formula in Arab traditional markets.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'عاوز إيه؟',
        phoneticGuide: 'Aawez eh?',
        englishMeaning: 'What do you want?',
        question: 'How do you say Egyptian "عاوز إيه؟" in Saudi Arabic?',
        options: ['وش تبغى؟', 'فين رايح؟', 'شلونك؟', 'إزيك؟'],
        correctOptionIndex: 0,
        culturalTip: 'Saudi uses "وش تبغى؟" or "وش تبي؟", while Egyptian uses "عاوز".',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'الحساب لو سمحت، كثر خيرك',
        phoneticGuide: 'Al-hisaab law samaht, kethar kheirak',
        englishMeaning: 'The bill please, may your blessings multiply',
        culturalTip: '"كثر خيرك" is a cherished Arab prayer given to restaurant staff.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'طالع',
        phoneticGuide: 'Taali\'',
        englishMeaning: 'Look / See',
        question: 'What does "طالع" specifically mean in Emirati dialect?',
        options: ['Look / See', 'Walk away', 'Sleep', 'Eat'],
        correctOptionIndex: 0,
        culturalTip: 'In Emirati, "طالع" means to look or watch intently.',
      ),
    ];
  }

  List<ExerciseItem> _generateTier3Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'ألف مبروك! تستاهلون كل خير وبركة',
        phoneticGuide: 'Alf mabrook! Tistahloon kul kheir wa baraka',
        englishMeaning: 'A thousand congratulations! You deserve every blessing',
        culturalTip: 'Used for weddings, promotions, graduations, and new births.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'ما شاء الله تبارك الرحمن، المجلس عامر',
        phoneticGuide: 'Masha\'Allah tabaarak al-rahman, al-majlis aamer',
        englishMeaning: 'As God willed, the council is flourishing with guests',
        culturalTip: 'Traditional praise when entering a lively Arab living room (Majlis).',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'كويس',
        phoneticGuide: 'Kowayyes',
        englishMeaning: 'Good / Well',
        question: 'What is the Saudi equivalent of the Egyptian word "كويس" (Good)?',
        options: ['زين', 'تعبان', 'خربان', 'مش حلو'],
        correctOptionIndex: 0,
        culturalTip: 'Both Saudi and Emirati commonly use "زين" or "طيب".',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'الله يسلمك ويحفظك من كل شر',
        phoneticGuide: 'Allah ysalmak wa yahfadhak min kul sharr',
        englishMeaning: 'May God protect and keep you safe from all harm',
        culturalTip: 'Gentle prayer of gratitude when receiving help from someone.',
      ),
    ];
  }

  List<ExerciseItem> _generateTier4Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'فرصة سعيدة وتشرفنا بالتعاون معكم طال عمرك',
        phoneticGuide: 'Fursa sa\'eeda wa tasharrafna bil-ta\'awun ma\'akum taal omrak',
        englishMeaning: 'It was a great pleasure and honor collaborating with you',
        culturalTip: 'Flawless closing for business meetings across Riyadh, Dubai, and Abu Dhabi.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'طرّشلي التفاصيل على الواتساب الحين طال عمرك',
        phoneticGuide: 'Tarresh-li al-tafaseel ala al-whatsapp al-heen taal omrak',
        englishMeaning: 'Send me the details on WhatsApp now',
        culturalTip: 'In Emirati and Gulf Arabic, "طرّشلي" (Tarresh-li) is the authentic spoken term for "send me" (never stiff classical "أرسل لي"). In Egypt, people say "ابعتلي".',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'طرّشلي',
        phoneticGuide: 'Tarresh-li',
        englishMeaning: 'Send me',
        question: 'How do you say "Send to me" in authentic Emirati & Gulf Arabic?',
        options: ['طرّشلي', 'أرسل لي', 'ابعتلي', 'عطيني'],
        correctOptionIndex: 0,
        culturalTip: 'Gulf natives say "طرّشلي" (Tarresh-li), while Egyptians say "ابعتلي" (Eb\'atli).',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'ليش',
        phoneticGuide: 'Leish',
        englishMeaning: 'Why',
        question: 'How is "ليش" (Why) typically pronounced in Egyptian dialect?',
        options: ['ليه', 'مين', 'إمتى', 'كام'],
        correctOptionIndex: 0,
        culturalTip: 'Egyptian softens "ليش" into "ليه".',
      ),
    ];
  }

  List<ExerciseItem> _generateTier5Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'الصبر مفتاح الفرج، وكل تأخيرة فيها خيرة',
        phoneticGuide: 'Al-sabr miftaah al-faraj, wa kul ta\'kheera feeha kheira',
        englishMeaning: 'Patience is the key to relief, and every delay holds a hidden blessing',
        culturalTip: 'One of the most comforting and timeless Arab philosophical proverbs.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'اللي فات مات، ويلا نبدأ صفحة جديدة',
        phoneticGuide: 'Elly faat maat, wa yalla nebda safha gedeeda',
        englishMeaning: 'What has passed is gone, let us turn a fresh new page',
        culturalTip: 'Beloved Egyptian reconciliation proverb.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'معرفش',
        phoneticGuide: 'Ma\'arafsh',
        englishMeaning: 'I don\'t know',
        question: 'Which dialect exclusively adds the "ش" suffix for negation (e.g., معرفش)?',
        options: ['Egyptian (المصرية)', 'Saudi (السعودية)', 'Emirati (الإماراتية)', 'Omani'],
        correctOptionIndex: 0,
        culturalTip: 'The "ما...ش" negation sandwich is unique to Egyptian and North African Arabic.',
      ),
    ];
  }

  List<ExerciseItem> _generateTier6Exercises(int level) {
    return const [
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'كفو والله! رايتك بيضا وما قصرت في أي شي',
        phoneticGuide: 'Kafu wallah! Raayatak bayda wa ma qassart fee ayy shay',
        englishMeaning: 'Bravo indeed! Your banner is pristine and you fell short in nothing',
        culturalTip: 'The pinnacle of Gulf praise for supreme generosity and impeccable character.',
      ),
      ExerciseItem(
        type: ExerciseType.speechPractice,
        arabicPhrase: 'يا هلا باللي لفا، أسفرت وأنورت بحضوركم',
        phoneticGuide: 'Ya hala bil-lee lafa, asfarat wa anwarat bi-hudurikum',
        englishMeaning: 'Welcome to whoever arrived, the world shone and brightened with your presence',
        culturalTip: 'Classic Gulf poetic welcoming formula for high guests.',
      ),
      ExerciseItem(
        type: ExerciseType.dialectEquivalence,
        arabicPhrase: 'فديتك',
        phoneticGuide: 'Fdeitak',
        englishMeaning: 'May I be your ransom / Dear one',
        question: '"فديتك" is a deeply affectionate and polite term most typical of:',
        options: ['Gulf / Emirati', 'Egyptian', 'Moroccan', 'Sudanese'],
        correctOptionIndex: 0,
        culturalTip: '"فديتك" expresses warmth, care, and readiness to support the listener.',
      ),
    ];
  }
}
