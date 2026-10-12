import 'package:flutter/material.dart';
import '../data/models/dialect.dart';
import '../data/models/lesson_model.dart';
import '../data/repositories/curriculum_repository.dart';
import 'monetization_provider.dart';

class CurriculumProvider extends ChangeNotifier {
  final CurriculumRepository _curriculumRepository;
  final MonetizationProvider _monetizationProvider;

  List<CurriculumLevel> _levels = [];
  List<CurriculumLevel> get levels => _levels;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int _selectedTier = 1;
  int get selectedTier => _selectedTier;

  CurriculumProvider({
    required CurriculumRepository curriculumRepository,
    required MonetizationProvider monetizationProvider,
  })  : _curriculumRepository = curriculumRepository,
        _monetizationProvider = monetizationProvider {
    loadLevels(DialectType.saudi);
  }

  Future<void> loadLevels(DialectType dialect) async {
    _isLoading = true;
    notifyListeners();

    _levels = await _curriculumRepository.getLevels(dialect);

    _isLoading = false;
    notifyListeners();
  }

  void selectTier(int tier) {
    if (_selectedTier == tier) return;
    _selectedTier = tier;
    notifyListeners();
  }

  List<CurriculumLevel> getLevelsForTier(int tier) {
    return _levels.where((l) => l.tierNumber == tier).toList();
  }

  /// Attempts to start a level, deducting 1 heart
  bool startLevel(CurriculumLevel level, {required VoidCallback onOutOfHearts}) {
    final deducted = _monetizationProvider.deductLevelHeart();
    if (!deducted) {
      onOutOfHearts();
      return false;
    }
    return true;
  }

  Future<void> completeLevel(int levelNumber, int stars) async {
    await _curriculumRepository.saveLevelCompletion(levelNumber, stars);
    final level = _levels.firstWhere(
      (l) => l.levelNumber == levelNumber,
      orElse: () => _levels.first,
    );
    level.isCompleted = true;
    level.stars = stars;
    notifyListeners();
  }

  int get completedCount => _levels.where((l) => l.isCompleted).length;
}
