import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/features/settings/app_settings.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  test('round-trips a versioned local snapshot', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AppStorage(preferences);
    final session = GameSession.start(
      puzzleId: 'classic-2026-01-01',
      config: const GameConfig.classic(),
      targets: ['crane'],
    ).submit('cider', {'crane', 'cider'});

    await storage.save(
      session: session,
      stats: const PlayerStats(gamesPlayed: 4, wins: 3),
      settings: const AppSettings(highContrast: true),
    );
    final restored = storage.load();

    expect(restored.session?.guesses, ['cider']);
    expect(restored.stats.gamesPlayed, 4);
    expect(restored.settings.highContrast, isTrue);
  });

  test('ignores a corrupt snapshot', () async {
    SharedPreferences.setMockInitialValues({
      'verdict.app_state.v1': 'not-json',
    });
    final preferences = await SharedPreferences.getInstance();
    expect(AppStorage(preferences).load().session, isNull);
  });
}
