import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool get isAdLoaded => _isAdLoaded;

  bool _isAdShowing = false;
  bool get isAdShowing => _isAdShowing;

  AdService() {
    _initAdMob();
  }

  Future<void> _initAdMob() async {
    // Only initialize MobileAds on supported mobile platforms
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[AdService] Desktop/Web detected: Using simulated AdMob engine.');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdService] MobileAds init error: $e');
    }
  }

  String get _adUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      // Android Rewarded Video Test ID
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (!kIsWeb && Platform.isIOS) {
      // iOS Rewarded Video Test ID
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  void loadRewardedAd() {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] RewardedAd loaded successfully.');
          _rewardedAd = ad;
          _isAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  /// Plays the Rewarded Ad or gracefully simulates it on desktop/testing
  Future<bool> playRewardedAd({required Function() onRewardEarned}) async {
    final completer = Completer<bool>();

    if (_isAdLoaded && _rewardedAd != null) {
      _isAdShowing = true;
      notifyListeners();

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdShowing = false;
          _isAdLoaded = false;
          loadRewardedAd();
          notifyListeners();
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdShowing = false;
          _isAdLoaded = false;
          loadRewardedAd();
          notifyListeners();
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
          onRewardEarned();
        },
      );

      return completer.future;
    } else {
      // Simulate sponsor ad play smoothly
      _isAdShowing = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      _isAdShowing = false;
      notifyListeners();
      onRewardEarned();
      loadRewardedAd();
      return true;
    }
  }
}
