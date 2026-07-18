import 'package:flutter_test/flutter_test.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  const words = {'crane', 'cider'};

  GameSession win(String id) => GameSession.start(
    puzzleId: id,
    config: const GameConfig.classic(),
    targets: ['crane'],
  ).submit('cider', words).submit('crane', words);

  test('records wins once and advances consecutive UTC streaks', () {
    var stats = const PlayerStats();
    final first = win('classic-2026-01-01');
    stats = stats.record(first, DateTime.utc(2026, 1, 1));
    stats = stats.record(first, DateTime.utc(2026, 1, 1));
    stats = stats.record(win('classic-2026-01-02'), DateTime.utc(2026, 1, 2));

    expect(stats.gamesPlayed, 2);
    expect(stats.wins, 2);
    expect(stats.currentStreak, 2);
    expect(stats.guessDistribution[2], 2);
  });

  test('a missed day restarts the streak', () {
    var stats = const PlayerStats().record(
      win('classic-2026-01-01'),
      DateTime.utc(2026, 1, 1),
    );
    stats = stats.record(win('classic-2026-01-03'), DateTime.utc(2026, 1, 3));
    expect(stats.currentStreak, 1);
    expect(stats.maxStreak, 1);
  });

  test('an expired streak is not displayed before the next game', () {
    final stats = const PlayerStats()
        .record(win('classic-2026-01-01'), DateTime.utc(2026, 1, 1))
        .asOf(DateTime.utc(2026, 1, 3));
    expect(stats.currentStreak, 0);
    expect(stats.maxStreak, 1);
  });
}
