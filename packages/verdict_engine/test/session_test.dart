import 'dart:convert';

import 'package:test/test.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  const words = {'crane', 'cider', 'apple', 'allee'};

  test('plays a winning game and survives serialization', () {
    var game = GameSession.start(
      puzzleId: 'classic-2026-01-01',
      config: const GameConfig.classic(),
      targets: ['crane'],
    );
    game = game.submit('cider', words).submit('crane', words);

    expect(game.status, GameStatus.won);
    expect(game.solvedAtGuess, [2]);
    expect(
      GameSession.fromJson(
        Map<String, Object?>.from(jsonDecode(jsonEncode(game.toJson())) as Map),
      ).toJson(),
      game.toJson(),
    );
  });

  test('rejects invalid submissions', () {
    final game = GameSession.start(
      puzzleId: 'puzzle',
      config: const GameConfig.classic(),
      targets: ['crane'],
    );
    expect(
      () => game.submit('no', words),
      throwsA(
        isA<SubmissionException>().having(
          (error) => error.error,
          'error',
          SubmissionError.invalidLength,
        ),
      ),
    );
    expect(
      () => game.submit('zzzzz', words),
      throwsA(isA<SubmissionException>()),
    );
  });

  test('vault locks missed keys', () {
    var game = GameSession.start(
      puzzleId: 'puzzle',
      config: const GameConfig.vault(),
      targets: ['crane'],
    );
    game = game.submit('cider', words);
    expect(
      () => game.submit('cider', words),
      throwsA(
        isA<SubmissionException>().having(
          (error) => error.error,
          'error',
          SubmissionError.lockedLetter,
        ),
      ),
    );
  });

  test('twin requires both answers', () {
    var game = GameSession.start(
      puzzleId: 'puzzle',
      config: const GameConfig.twin(),
      targets: ['crane', 'cider'],
    );
    game = game.submit('crane', words);
    expect(game.status, GameStatus.active);
    game = game.submit('cider', words);
    expect(game.status, GameStatus.won);
  });
}
