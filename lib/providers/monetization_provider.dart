import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/dialect_matrix.dart';
import '../data/models/dialect.dart';

class MonetizationProvider extends ChangeNotifier {
  static const String _keyHearts = 'hala_user_hearts';
  static const String _keyStreak = 'hala_user_streak_days';
  static const String _keyLastStreakDate = 'hala_last_streak_date';

  int _hearts = 15; // Initial Starter: 15 Hearts
  int get hearts => _hearts;

  int _streakDays = 1;
  int get streakDays => _streakDays;

  bool _hasDailyBonusClaimedToday = false;
  bool get hasDailyBonusClaimedToday => _hasDailyBonusClaimedToday;

  MonetizationProvider() {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hearts = prefs.getInt(_keyHearts) ?? 15;
      _streakDays = prefs.getInt(_keyStreak) ?? 1;

      final lastDateStr = prefs.getString(_keyLastStreakDate);
      if (lastDateStr != null) {
        final lastDate = DateTime.tryParse(lastDateStr);
        final now = DateTime.now();
        if (lastDate != null) {
          final isSameDay = lastDate.year == now.year &&
              lastDate.month == now.month &&
              lastDate.day == now.day;
          _hasDailyBonusClaimedToday = isSameDay;

          // Check if streak was broken (more than 48 hours)
          if (now.difference(lastDate).inHours > 48) {
            _streakDays = 1;
            await prefs.setInt(_keyStreak, _streakDays);
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Claims daily 24-hour streak bonus (+10 Hearts)
  Future<bool> claimDailyStreakBonus() async {
    if (_hasDailyBonusClaimedToday) return false;

    _hearts += 10;
    _streakDays += 1;
    _hasDailyBonusClaimedToday = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyHearts, _hearts);
      await prefs.setInt(_keyStreak, _streakDays);
      await prefs.setString(_keyLastStreakDate, DateTime.now().toIso8601String());
    } catch (_) {}

    notifyListeners();
    return true;
  }

  /// Deducts 1 Heart for a speaking turn in the Conversation Salon
  bool deductSpeakingTurnHeart() {
    if (_hearts <= 0) return false;
    _hearts -= 1;
    _saveHearts();
    notifyListeners();
    return true;
  }

  /// Deducts 1 Heart for starting a level checkpoint
  bool deductLevelHeart() {
    if (_hearts <= 0) return false;
    _hearts -= 1;
    _saveHearts();
    notifyListeners();
    return true;
  }

  /// Grants +15 Hearts after completing the Active Recall Ad-Bridge challenge
  Future<void> grantAdBridgeRefuel() async {
    _hearts += 15;
    await _saveHearts();
    notifyListeners();
  }

  /// Direct grant for starter onboarding (+15 Hearts)
  Future<void> grantStarterHearts() async {
    _hearts = 15;
    await _saveHearts();
    notifyListeners();
  }

  Future<void> _saveHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyHearts, _hearts);
    } catch (_) {}
  }

  /// Picks a target dialect phrase for the Active Recall Ad-Bridge sequence
  DialectMatrixItem getRandomChallengePhrase(DialectType dialect) {
    final list = DialectMatrix.items;
    return (list..shuffle()).first;
  }
}
