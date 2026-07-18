import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
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
    );
  });

  tearDown(() => container.dispose());

  test('submits keyboard input and records the result', () async {
    final controller = container.read(gameControllerProvider.notifier);
    for (final letter in 'crane'.split('')) {
      controller.addLetter(letter);
    }
    expect(await controller.submit(), isTrue);

    final state = container.read(gameControllerProvider);
    expect(state.session.status, GameStatus.won);
    expect(state.stats.gamesPlayed, 1);
    expect(state.resultVisible, isTrue);
  });

  test('keeps an invalid word in the draft', () async {
    final controller = container.read(gameControllerProvider.notifier);
    for (final letter in 'zzzzz'.split('')) {
      controller.addLetter(letter);
    }
    expect(await controller.submit(), isFalse);

    final state = container.read(gameControllerProvider);
    expect(state.draft, 'zzzzz');
    expect(state.errorMessage, isNotNull);
  });
}
