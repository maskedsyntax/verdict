import 'package:flutter_test/flutter_test.dart';
import 'package:verdict/features/results/share_result.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  test('creates a spoiler-safe emoji result', () {
    final session = GameSession.start(
      puzzleId: 'classic-2026-01-01',
      config: const GameConfig.classic(),
      targets: ['crane'],
    ).submit('cider', {'crane', 'cider'}).submit('crane', {'crane', 'cider'});

    final result = formatShareResult(session: session, number: 1);
    expect(result, startsWith('VERDICT #1 2/6'));
    expect(result, isNot(contains('crane')));
    expect(result, contains('🟩🟩🟩🟩🟩'));
  });
}
