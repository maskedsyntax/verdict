import 'dart:io';

import 'package:flutter/foundation.dart';

class AdMobConfig {
  const AdMobConfig({
    required this.appId,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.isConfigured,
  });

  factory AdMobConfig.forCurrentPlatform() {
    if (!Platform.isAndroid && !Platform.isIOS) return AdMobConfig.disabled;
    return AdMobConfig.resolve(
      isAndroid: Platform.isAndroid,
      isRelease: kReleaseMode,
      androidAppId: const String.fromEnvironment('ADMOB_ANDROID_APP_ID'),
      iosAppId: const String.fromEnvironment('ADMOB_IOS_APP_ID'),
      bannerAdUnitId: const String.fromEnvironment('ADMOB_BANNER_UNIT_ID'),
      interstitialAdUnitId: const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_UNIT_ID',
      ),
      rewardedAdUnitId: const String.fromEnvironment('ADMOB_REWARDED_UNIT_ID'),
    );
  }

  factory AdMobConfig.resolve({
    required bool isAndroid,
    required bool isRelease,
    String androidAppId = '',
    String iosAppId = '',
    String bannerAdUnitId = '',
    String interstitialAdUnitId = '',
    String rewardedAdUnitId = '',
  }) {
    if (!isRelease) {
      return isAndroid ? testAndroid : testIos;
    }
    final appId = isAndroid ? androidAppId : iosAppId;
    final ids = [appId, bannerAdUnitId, interstitialAdUnitId, rewardedAdUnitId];
    final valid = ids.every(
      (id) => id.isNotEmpty && !id.contains(_googleTestPublisherId),
    );
    return AdMobConfig(
      appId: appId,
      bannerAdUnitId: bannerAdUnitId,
      interstitialAdUnitId: interstitialAdUnitId,
      rewardedAdUnitId: rewardedAdUnitId,
      isConfigured: valid,
    );
  }

  static const _googleTestPublisherId = '3940256099942544';

  static const disabled = AdMobConfig(
    appId: '',
    bannerAdUnitId: '',
    interstitialAdUnitId: '',
    rewardedAdUnitId: '',
    isConfigured: false,
  );

  static const testAndroid = AdMobConfig(
    appId: 'ca-app-pub-3940256099942544~3347511713',
    bannerAdUnitId: 'ca-app-pub-3940256099942544/9214589741',
    interstitialAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
    rewardedAdUnitId: 'ca-app-pub-3940256099942544/5224354917',
    isConfigured: true,
  );

  static const testIos = AdMobConfig(
    appId: 'ca-app-pub-3940256099942544~1458002511',
    bannerAdUnitId: 'ca-app-pub-3940256099942544/2435281174',
    interstitialAdUnitId: 'ca-app-pub-3940256099942544/4411468910',
    rewardedAdUnitId: 'ca-app-pub-3940256099942544/1712485313',
    isConfigured: true,
  );

  final String appId;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final bool isConfigured;

  bool get isTestConfiguration => appId.contains(_googleTestPublisherId);
}
