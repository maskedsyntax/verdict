import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/core/services/future_services.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/settings/app_settings.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  late ProviderContainer container;
  late _FakeScheduler scheduler;
  late _FakeAdService adService;
  late AppStorage storage;

  Future<void> buildContainer() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    storage = AppStorage(preferences);
    scheduler = _FakeScheduler();
    adService = _FakeAdService();
    container = ProviderContainer(
      overrides: [
        appStorageProvider.overrideWithValue(storage),
        wordRepositoryProvider.overrideWithValue(
          const WordRepository(
            answers: ['crane'],
            validGuesses: {'crane', 'cider'},
          ),
        ),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 1, 1)),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        adServiceProvider.overrideWithValue(adService),
      ],
    );
  }

  setUp(buildContainer);

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

  test('winning a puzzle cancels today\'s streak reminder', () async {
    final controller = container.read(gameControllerProvider.notifier);
    // Consume the schedule/cancel call made during build().
    scheduler.cancelled = 0;
    for (final letter in 'crane'.split('')) {
      controller.addLetter(letter);
    }
    await controller.submit();

    expect(scheduler.cancelled, 1);
  });

  test(
    'an active streak with an unsolved puzzle schedules a reminder on build',
    () async {
      await storage.save(
        session: GameSession.start(
          puzzleId: 'classic-2026-01-01',
          config: const GameConfig.classic(),
          targets: const ['crane'],
        ),
        stats: const PlayerStats(
          gamesPlayed: 3,
          wins: 3,
          currentStreak: 3,
          maxStreak: 3,
          lastWinDate: '2025-12-31',
        ),
        settings: const AppSettings(streakReminder: true),
      );
      container.read(gameControllerProvider.notifier);

      expect(scheduler.scheduled, 1);
    },
  );

  test('disabling the reminder setting cancels it', () async {
    final controller = container.read(gameControllerProvider.notifier);
    scheduler.cancelled = 0;
    await controller.setStreakReminder(false);

    expect(scheduler.cancelled, 1);
  });

  test('shows a post-game ad only once the puzzle is completed', () async {
    final controller = container.read(gameControllerProvider.notifier);
    for (final letter in 'zzzzz'.split('')) {
      controller.addLetter(letter);
    }
    await controller.submit();
    expect(adService.shown, 0);

    for (var i = 0; i < 5; i++) {
      controller.removeLetter();
    }
    for (final letter in 'crane'.split('')) {
      controller.addLetter(letter);
    }
    await controller.submit();

    expect(adService.shown, 1);
  });
}

class _FakeScheduler implements NotificationScheduler {
  int scheduled = 0;
  int cancelled = 0;

  @override
  Future<void> scheduleDailyReminder() async {
    scheduled++;
  }

  @override
  Future<void> cancelDailyReminder() async {
    cancelled++;
  }
}

class _FakeAdService implements AdService {
  int shown = 0;

  @override
  bool get isEnabled => true;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> showPostGameAd() async {
    shown++;
  }

  @override
  Future<bool> showPrivacyOptions() async => true;

  @override
  Future<bool> showRewardedHint(FutureOr<void> Function() onReward) async {
    await Future<void>.sync(onReward);
    return true;
  }

  @override
  void dispose() {}
}
