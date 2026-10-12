import 'package:flutter/material.dart';
import '../data/models/dialect.dart';
import '../data/repositories/user_preferences_repository.dart';

class AppStateProvider extends ChangeNotifier {
  final UserPreferencesRepository _preferencesRepository;

  DialectType _activeDialect = DialectType.saudi;
  DialectType get activeDialect => _activeDialect;

  // Rule 3: Default display language is English ('en')
  String _displayLanguage = 'en';
  String get displayLanguage => _displayLanguage;

  bool _isOnboardingCompleted = false;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  String _userGoal = 'Daily Social Fluency ☕';
  String get userGoal => _userGoal;

  String _userProficiency = 'Novice';
  String get userProficiency => _userProficiency;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppStateProvider({required UserPreferencesRepository preferencesRepository})
      : _preferencesRepository = preferencesRepository {
    _loadState();
  }

  Future<void> _loadState() async {
    _activeDialect = await _preferencesRepository.getActiveDialect();
    _displayLanguage = await _preferencesRepository.getDisplayLanguage();
    _isOnboardingCompleted = await _preferencesRepository.isOnboardingCompleted();
    _userGoal = await _preferencesRepository.getUserGoal();
    _userProficiency = await _preferencesRepository.getProficiencyLevel();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setActiveDialect(DialectType dialect) async {
    if (_activeDialect == dialect) return;
    _activeDialect = dialect;
    await _preferencesRepository.saveActiveDialect(dialect);
    notifyListeners();
  }

  Future<void> setDisplayLanguage(String langCode) async {
    if (_displayLanguage == langCode) return;
    _displayLanguage = langCode;
    await _preferencesRepository.saveDisplayLanguage(langCode);
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required DialectType dialect,
    required String goal,
    required String proficiency,
  }) async {
    _activeDialect = dialect;
    _userGoal = goal;
    _userProficiency = proficiency;
    _isOnboardingCompleted = true;

    await _preferencesRepository.saveActiveDialect(dialect);
    await _preferencesRepository.saveUserGoal(goal);
    await _preferencesRepository.saveProficiencyLevel(proficiency);
    await _preferencesRepository.setOnboardingCompleted(true);
    notifyListeners();
  }
}
