import 'package:verdict_engine/verdict_engine.dart';

class PlayerStats {
  const PlayerStats({
    this.gamesPlayed = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const {},
    this.completedPuzzleIds = const {},
    this.lastWinDate,
  });

  final int gamesPlayed;
  final int wins;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution;
  final Set<String> completedPuzzleIds;
  final String? lastWinDate;

  int get winPercentage =>
      gamesPlayed == 0 ? 0 : ((wins / gamesPlayed) * 100).round();

  PlayerStats asOf(DateTime utcDate) {
    if (currentStreak == 0 || lastWinDate == null) return this;
    final lastDate = DateTime.parse(lastWinDate!);
    if (utcDate.toUtc().difference(lastDate).inDays <= 1) return this;
    return PlayerStats(
      gamesPlayed: gamesPlayed,
      wins: wins,
      currentStreak: 0,
      maxStreak: maxStreak,
      guessDistribution: guessDistribution,
      completedPuzzleIds: completedPuzzleIds,
      lastWinDate: lastWinDate,
    );
  }

  PlayerStats record(GameSession session, DateTime puzzleDate) {
    if (session.status == GameStatus.active ||
        completedPuzzleIds.contains(session.puzzleId)) {
      return this;
    }

    final won = session.status == GameStatus.won;
    final dateKey = DailyPuzzleResolver.dateKey(puzzleDate);
    var nextStreak = 0;
    if (won) {
      final lastDate = lastWinDate == null
          ? null
          : DateTime.parse(lastWinDate!);
      final daysSinceLastWin = lastDate == null
          ? null
          : puzzleDate.toUtc().difference(lastDate).inDays;
      nextStreak = daysSinceLastWin == 1 ? currentStreak + 1 : 1;
    }
    final nextDistribution = Map<int, int>.from(guessDistribution);
    if (won) {
      nextDistribution.update(
        session.guesses.length,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return PlayerStats(
      gamesPlayed: gamesPlayed + 1,
      wins: wins + (won ? 1 : 0),
      currentStreak: nextStreak,
      maxStreak: nextStreak > maxStreak ? nextStreak : maxStreak,
      guessDistribution: Map.unmodifiable(nextDistribution),
      completedPuzzleIds: Set.unmodifiable({
        ...completedPuzzleIds,
        session.puzzleId,
      }),
      lastWinDate: won ? dateKey : lastWinDate,
    );
  }

  Map<String, Object?> toJson() => {
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'currentStreak': currentStreak,
    'maxStreak': maxStreak,
    'guessDistribution': guessDistribution.map(
      (guess, count) => MapEntry('$guess', count),
    ),
    'completedPuzzleIds': completedPuzzleIds.toList(),
    'lastWinDate': lastWinDate,
  };

  factory PlayerStats.fromJson(Map<String, Object?> json) {
    final rawDistribution = Map<String, Object?>.from(
      (json['guessDistribution'] as Map?) ?? const {},
    );
    return PlayerStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      guessDistribution: rawDistribution.map(
        (guess, count) => MapEntry(int.parse(guess), count! as int),
      ),
      completedPuzzleIds: Set<String>.from(
        (json['completedPuzzleIds'] as List?) ?? const [],
      ),
      lastWinDate: json['lastWinDate'] as String?,
    );
  }
}
