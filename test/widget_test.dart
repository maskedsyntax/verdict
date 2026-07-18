import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/app/verdict_app.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/game/game_controller.dart';

void main() {
  testWidgets('renders the daily game on a compact phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appStorageProvider.overrideWithValue(AppStorage(preferences)),
          wordRepositoryProvider.overrideWithValue(
            const WordRepository(
              answers: ['crane'],
              validGuesses: {'crane', 'cider'},
            ),
          ),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 1, 1)),
        ],
        child: const VerdictApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VERDICT'), findsOneWidget);
    expect(find.text('DAILY CASE #1'), findsOneWidget);
    expect(find.text('ENTER'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
