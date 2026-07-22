import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:verdict/core/services/service_providers.dart';

class BannerAdSlot extends ConsumerStatefulWidget {
  const BannerAdSlot({super.key});

  @override
  ConsumerState<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends ConsumerState<BannerAdSlot> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  int? _requestedWidth;
  int _loadAttempts = 0;

  Future<void> _load(int width) async {
    if (_requestedWidth == width) return;
    _requestedWidth = width;
    _loaded = false;
    await _bannerAd?.dispose();
    _bannerAd = null;

    final unitId = ref.read(bannerAdUnitIdProvider);
    final service = ref.read(adServiceProvider);
    if (unitId == null || !await service.initialize() || !mounted) return;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted || _requestedWidth != width) return;

    late final BannerAd ad;
    ad = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _loadAttempts = 0;
          if (!mounted || _bannerAd != ad) {
            unawaited(ad.dispose());
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (_, error) {
          if (kDebugMode) debugPrint('AdMob: Banner load failed: $error');
          unawaited(ad.dispose());
          if (mounted && _bannerAd == ad) {
            setState(() {
              _bannerAd = null;
              _loaded = false;
            });
            if (++_loadAttempts < 3) {
              Future<void>.delayed(const Duration(seconds: 3), () {
                if (!mounted || _requestedWidth != width) return;
                setState(() => _requestedWidth = null);
              });
            }
          }
        },
      ),
    );
    _bannerAd = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.floor();
      if (width > 0 && width != _requestedWidth) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
      }
      final ad = _bannerAd;
      if (!_loaded || ad == null) return const SizedBox.shrink();
      return Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      );
    },
  );
}
