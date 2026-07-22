import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:verdict/core/services/admob_config.dart';
import 'package:verdict/core/services/future_services.dart';

class AdMobAdService implements AdService {
  AdMobAdService(this._config);

  final AdMobConfig _config;
  Future<bool>? _initialization;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _sdkInitialized = false;
  bool _shownThisSession = false;
  bool _disposed = false;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;

  @override
  bool get isEnabled => _config.isConfigured && !_disposed;

  @override
  Future<bool> initialize() =>
      _initialization ??= _requestConsentAndInitialize();

  Future<bool> _requestConsentAndInitialize() {
    if (!isEnabled) return Future.value(false);
    final completer = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) _debugLog('Consent form: $error');
        });
        completer.complete(await _initializeIfAllowed());
      },
      (error) async {
        _debugLog('Consent update: $error');
        completer.complete(await _initializeIfAllowed());
      },
    );
    return completer.future;
  }

  Future<bool> _initializeIfAllowed() async {
    final canRequestAds = await ConsentInformation.instance.canRequestAds();
    final allowTestAds = _config.isTestConfiguration && kDebugMode;
    if (_disposed || (!canRequestAds && !allowTestAds)) {
      _debugLog('Ads blocked until consent allows requests.');
      return false;
    }
    if (!canRequestAds && allowTestAds) {
      _debugLog('Using debug-only Google test ads after consent setup error.');
    }
    if (!_sdkInitialized) {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
      _loadInterstitial();
      _loadRewarded();
    }
    return true;
  }

  void _loadInterstitial() {
    if (_disposed || !_sdkInitialized || _interstitialAd != null) return;
    InterstitialAd.load(
      adUnitId: _config.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoadAttempts = 0;
          if (_disposed) {
            ad.dispose();
          } else {
            _interstitialAd = ad;
          }
        },
        onAdFailedToLoad: (error) {
          _debugLog('Interstitial load failed: $error');
          _interstitialAd = null;
          if (++_interstitialLoadAttempts < 3) {
            Future<void>.delayed(const Duration(seconds: 3), _loadInterstitial);
          }
        },
      ),
    );
  }

  void _loadRewarded() {
    if (_disposed || !_sdkInitialized || _rewardedAd != null) return;
    RewardedAd.load(
      adUnitId: _config.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoadAttempts = 0;
          if (_disposed) {
            ad.dispose();
          } else {
            _rewardedAd = ad;
          }
        },
        onAdFailedToLoad: (error) {
          _debugLog('Rewarded load failed: $error');
          _rewardedAd = null;
          if (++_rewardedLoadAttempts < 3) {
            Future<void>.delayed(const Duration(seconds: 3), _loadRewarded);
          }
        },
      ),
    );
  }

  @override
  Future<void> showPostGameAd() async {
    if (_shownThisSession || !await initialize()) return;
    final ad = _interstitialAd;
    if (ad == null) return;
    _shownThisSession = true;
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, _) => ad.dispose(),
    );
    try {
      await ad.show();
    } on Object {
      await ad.dispose();
    }
  }

  @override
  Future<bool> showRewardedHint(FutureOr<void> Function() onReward) async {
    if (!await initialize()) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewardedAd = null;
    final completer = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    try {
      await ad.show(
        onUserEarnedReward: (_, reward) {
          if (earned) return;
          earned = true;
          unawaited(Future<void>.sync(onReward));
        },
      );
    } on Object {
      await ad.dispose();
      _loadRewarded();
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  @override
  Future<bool> showPrivacyOptions() async {
    final requirement = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    if (requirement != PrivacyOptionsRequirementStatus.required) return false;
    final completer = Completer<bool>();
    await ConsentForm.showPrivacyOptionsForm(
      (error) => completer.complete(error == null),
    );
    return completer.future;
  }

  @override
  void dispose() {
    _disposed = true;
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }

  void _debugLog(String message) {
    if (kDebugMode) debugPrint('AdMob: $message');
  }
}
