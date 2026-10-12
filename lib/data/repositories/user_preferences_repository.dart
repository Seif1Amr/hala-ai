import 'package:shared_preferences/shared_preferences.dart';
import '../models/dialect.dart';

class UserPreferencesRepository {
  static const String _keyDialect = 'hala_active_dialect';
  static const String _keyLang = 'hala_display_language';
  static const String _keyOnboarding = 'hala_onboarding_completed';
  static const String _keyGoal = 'hala_user_goal';
  static const String _keyProficiency = 'hala_user_proficiency';

  Future<DialectType> getActiveDialect() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyDialect) ?? DialectType.saudi.name;
    return DialectType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => DialectType.saudi,
    );
  }

  Future<void> saveActiveDialect(DialectType dialect) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDialect, dialect.name);
  }

  Future<String> getDisplayLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    // Rule 3: Default display language is English ('en')
    return prefs.getString(_keyLang) ?? 'en';
  }

  Future<void> saveDisplayLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, languageCode);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, completed);
  }

  Future<String> getUserGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGoal) ?? 'Daily Social Fluency ☕';
  }

  Future<void> saveUserGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGoal, goal);
  }

  Future<String> getProficiencyLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProficiency) ?? 'Novice';
  }

  Future<void> saveProficiencyLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProficiency, level);
  }
}
