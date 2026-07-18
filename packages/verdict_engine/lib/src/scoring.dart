import 'models.dart';

int calculateScore({
  required GameConfig config,
  required GameStatus status,
  required int guessesUsed,
  int? elapsedSeconds,
}) {
  if (status != GameStatus.won) return 0;
  final remainingBonus = (config.maxGuesses - guessesUsed).clamp(0, 100) * 100;
  var score = (1000 + remainingBonus) * config.scoreMultiplier;
  if (config.timeLimitSeconds case final limit?) {
    score += ((limit - (elapsedSeconds ?? limit)).clamp(0, limit)) * 10;
  }
  return score;
}
