import 'package:test/test.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  final resolver = DailyPuzzleResolver(
    answers: ['crane', 'cider', 'apple'],
    epoch: DateTime.utc(2026, 1, 1),
  );

  test('resolves stable UTC puzzle IDs', () {
    final puzzle = resolver.resolve(
      DateTime.parse('2026-01-02T23:30:00-05:00'),
    );
    expect(puzzle.id, 'classic-2026-01-03');
    expect(puzzle.number, 3);
    expect(puzzle.answers, ['apple']);
  });

  test('shift guess counts scale with word length', () {
    expect(GameConfig.shift(4).maxGuesses, 5);
    expect(GameConfig.shift(7).maxGuesses, 8);
    expect(() => GameConfig.shift(8), throwsArgumentError);
  });

  test('scores wins using remaining guesses', () {
    expect(
      calculateScore(
        config: const GameConfig.classic(),
        status: GameStatus.won,
        guessesUsed: 3,
      ),
      1300,
    );
  });
}
