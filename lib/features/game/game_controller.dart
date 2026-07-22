import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/settings/app_settings.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

final appStorageProvider = Provider<AppStorage>(
  (ref) => throw UnimplementedError('AppStorage must be overridden.'),
);

final wordRepositoryProvider = Provider<WordRepository>(
  (ref) => throw UnimplementedError('WordRepository must be overridden.'),
);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final gameControllerProvider = NotifierProvider<GameController, GameViewState>(
  GameController.new,
);

class GameViewState {
  const GameViewState({
    required this.puzzle,
    required this.session,
    required this.stats,
    required this.settings,
    this.draft = '',
    this.errorMessage,
    this.resultVisible = false,
    this.revealedHints = const {},
  });

  final DailyPuzzle puzzle;
  final GameSession session;
  final PlayerStats stats;
  final AppSettings settings;
  final String draft;
  final String? errorMessage;
  final bool resultVisible;
  final Set<String> revealedHints;

  GameViewState copyWith({
    GameSession? session,
    PlayerStats? stats,
    AppSettings? settings,
    String? draft,
    String? errorMessage,
    bool clearError = false,
    bool? resultVisible,
    Set<String>? revealedHints,
  }) => GameViewState(
    puzzle: puzzle,
    session: session ?? this.session,
    stats: stats ?? this.stats,
    settings: settings ?? this.settings,
    draft: draft ?? this.draft,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    resultVisible: resultVisible ?? this.resultVisible,
    revealedHints: revealedHints ?? this.revealedHints,
  );
}

class GameController extends Notifier<GameViewState> {
  late AppStorage _storage;
  late WordRepository _words;

  @override
  GameViewState build() {
    _storage = ref.watch(appStorageProvider);
    _words = ref.watch(wordRepositoryProvider);
    final stored = _storage.load();
    final puzzle = DailyPuzzleResolver(
      answers: _words.answers,
    ).resolve(ref.watch(clockProvider)());
    final restored = stored.session;
    final session = restored?.puzzleId == puzzle.id
        ? restored!
        : GameSession.start(
            puzzleId: puzzle.id,
            config: const GameConfig.classic(),
            targets: puzzle.answers,
          );
    final state = GameViewState(
      puzzle: puzzle,
      session: session,
      stats: stored.stats.asOf(puzzle.utcDate),
      settings: stored.settings,
      resultVisible: session.status != GameStatus.active,
      revealedHints: stored.hintPuzzleId == puzzle.id
          ? stored.revealedHints
          : const {},
    );
    _syncReminder(state);
    return state;
  }

  void addLetter(String letter) {
    if (state.session.status != GameStatus.active ||
        state.draft.length >= state.session.config.wordLength) {
      return;
    }
    final normalized = letter.toLowerCase();
    if (!RegExp(r'^[a-z]$').hasMatch(normalized)) return;
    state = state.copyWith(
      draft: '${state.draft}$normalized',
      clearError: true,
    );
  }

  void removeLetter() {
    if (state.draft.isEmpty) return;
    state = state.copyWith(
      draft: state.draft.substring(0, state.draft.length - 1),
      clearError: true,
    );
  }

  Future<bool> submit() async {
    try {
      final session = state.session.submit(state.draft, _words.validGuesses);
      final completed = session.status != GameStatus.active;
      final stats = completed
          ? state.stats.record(session, state.puzzle.utcDate)
          : state.stats;
      state = state.copyWith(
        session: session,
        stats: stats,
        draft: '',
        clearError: true,
        resultVisible: completed,
      );
      await _persist();
      _syncReminder(state);
      if (completed) {
        unawaited(ref.read(adServiceProvider).showPostGameAd());
      }
      return true;
    } on SubmissionException catch (error) {
      state = state.copyWith(errorMessage: _messageFor(error));
      return false;
    }
  }

  Future<void> setHighContrast(bool enabled) async {
    state = state.copyWith(
      settings: state.settings.copyWith(highContrast: enabled),
    );
    await _persist();
  }

  Future<void> setStreakReminder(bool enabled) async {
    state = state.copyWith(
      settings: state.settings.copyWith(streakReminder: enabled),
    );
    await _persist();
    _syncReminder(state);
  }

  Future<void> revealHint() async {
    if (state.session.status != GameStatus.active) return;
    final available = state.session.targets.first
        .split('')
        .where((letter) => !state.revealedHints.contains(letter));
    if (available.isEmpty) return;
    state = state.copyWith(
      revealedHints: Set.unmodifiable({
        ...state.revealedHints,
        available.first,
      }),
      clearError: true,
    );
    await _persist();
  }

  void dismissError() => state = state.copyWith(clearError: true);

  void closeResult() => state = state.copyWith(resultVisible: false);

  Future<void> _persist() => _storage.save(
    session: state.session,
    stats: state.stats,
    settings: state.settings,
    hintPuzzleId: state.puzzle.id,
    revealedHints: state.revealedHints,
  );

  void _syncReminder(GameViewState viewState) {
    final shouldRemind =
        viewState.settings.streakReminder &&
        viewState.session.status == GameStatus.active &&
        viewState.stats.currentStreak > 0;
    final scheduler = ref.read(notificationSchedulerProvider);
    if (shouldRemind) {
      unawaited(scheduler.scheduleDailyReminder());
    } else {
      unawaited(scheduler.cancelDailyReminder());
    }
  }

  String _messageFor(SubmissionException exception) =>
      switch (exception.error) {
        SubmissionError.invalidLength =>
          'Your verdict needs ${state.session.config.wordLength} letters.',
        SubmissionError.unknownWord => 'That word is not in the record.',
        SubmissionError.gameOver => 'Today\'s verdict is already final.',
        SubmissionError.lockedLetter =>
          '${exception.letter?.toUpperCase()} is locked for this mode.',
      };
}
