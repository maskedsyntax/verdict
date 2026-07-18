import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verdict/core/services/future_services.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/leaderboard/leaderboard_sheet.dart';
import 'package:verdict/features/settings/app_settings.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  final puzzle = DailyPuzzle(
    id: 'classic-2026-01-01',
    number: 1,
    utcDate: DateTime.utc(2026, 1, 1),
    answers: const ['crane'],
  );

  GameViewState game({bool won = false}) {
    var session = GameSession.start(
      puzzleId: puzzle.id,
      config: const GameConfig.classic(),
      targets: puzzle.answers,
    );
    if (won) session = session.submit('crane', {'crane'});
    return GameViewState(
      puzzle: puzzle,
      session: session,
      stats: const PlayerStats(),
      settings: const AppSettings(),
    );
  }

  testWidgets('shows an offline state when Supabase is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LeaderboardSheet(game: game())),
      ),
    );
    await tester.pump();

    expect(find.text('GLOBAL BOARD'), findsOneWidget);
    expect(find.textContaining('not connected'), findsOneWidget);
  });

  testWidgets('loads scores and posts a completed game', (tester) async {
    final services = _FakeServices();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onlineServicesEnabledProvider.overrideWithValue(true),
          leaderboardRepositoryProvider.overrideWithValue(services),
          authServiceProvider.overrideWithValue(services),
        ],
        child: MaterialApp(home: LeaderboardSheet(game: game(won: true))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('1900'), findsOneWidget);
    await tester.tap(find.text("POST TODAY'S SCORE"));
    await tester.pumpAndSettle();

    expect(services.submitted, isTrue);
    expect(find.text('Score posted: 1500'), findsOneWidget);
  });
}

class _FakeServices implements LeaderboardRepository, AuthService {
  bool submitted = false;

  @override
  Future<String> claimUsername(String username) async => username;

  @override
  Future<String?> currentUsername() async => 'Ada';

  @override
  Future<String> signInAnonymously() async => 'user-id';

  @override
  Future<int> submitAttempt(VerifiedAttempt attempt) async {
    submitted = true;
    return 1500;
  }

  @override
  Future<List<LeaderboardEntry>> topScores(GameMode mode) async => const [
    LeaderboardEntry(username: 'Ada', score: 1900),
  ];
}
