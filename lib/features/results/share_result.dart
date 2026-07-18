import 'package:verdict_engine/verdict_engine.dart';

String formatShareResult({required GameSession session, required int number}) {
  final result = session.status == GameStatus.won
      ? '${session.guesses.length}/${session.config.maxGuesses}'
      : 'X/${session.config.maxGuesses}';
  final rows = session.evaluations
      .map((evaluation) {
        return evaluation.first.map(_emojiFor).join();
      })
      .join('\n');
  return 'VERDICT #$number $result\n\n$rows';
}

String _emojiFor(LetterGrade grade) => switch (grade) {
  LetterGrade.hit => '🟩',
  LetterGrade.near => '🟨',
  LetterGrade.miss => '⬛',
};
