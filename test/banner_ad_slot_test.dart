import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:verdict/features/ads/banner_ad_slot.dart';

void main() {
  testWidgets('renders nothing when no banner unit id is configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: BannerAdSlot())),
      ),
    );
    await tester.pump();

    expect(find.byType(AdWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
