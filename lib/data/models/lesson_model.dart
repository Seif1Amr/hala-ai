enum ExerciseType {
  speechPractice,
  dialectEquivalence,
}

class ExerciseItem {
  final ExerciseType type;
  final String arabicPhrase;
  final String phoneticGuide;
  final String englishMeaning;
  final String? question;
  final List<String>? options;
  final int? correctOptionIndex;
  final String? culturalTip;

  const ExerciseItem({
    required this.type,
    required this.arabicPhrase,
    required this.phoneticGuide,
    required this.englishMeaning,
    this.question,
    this.options,
    this.correctOptionIndex,
    this.culturalTip,
  });
}

class CurriculumLevel {
  final int levelNumber;
  final int tierNumber;
  final String tierTitle;
  final String title;
  final String titleAr;
  final String objective;
  final List<ExerciseItem> exercises;
  bool isCompleted;
  int stars;

  CurriculumLevel({
    required this.levelNumber,
    required this.tierNumber,
    required this.tierTitle,
    required this.title,
    required this.titleAr,
    required this.objective,
    required this.exercises,
    this.isCompleted = false,
    this.stars = 0,
  });
}
