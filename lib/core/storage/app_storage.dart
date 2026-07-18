import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/features/settings/app_settings.dart';
import 'package:verdict/features/stats/player_stats.dart';
import 'package:verdict_engine/verdict_engine.dart';

class StoredAppState {
  const StoredAppState({
    this.session,
    this.stats = const PlayerStats(),
    this.settings = const AppSettings(),
  });

  final GameSession? session;
  final PlayerStats stats;
  final AppSettings settings;
}

class AppStorage {
  const AppStorage(this._preferences);

  static const _stateKey = 'verdict.app_state.v1';
  final SharedPreferences _preferences;

  StoredAppState load() {
    final encoded = _preferences.getString(_stateKey);
    if (encoded == null) return const StoredAppState();
    try {
      final json = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      return StoredAppState(
        session: json['session'] == null
            ? null
            : GameSession.fromJson(
                Map<String, Object?>.from(json['session']! as Map),
              ),
        stats: PlayerStats.fromJson(
          Map<String, Object?>.from((json['stats'] as Map?) ?? const {}),
        ),
        settings: AppSettings.fromJson(
          Map<String, Object?>.from((json['settings'] as Map?) ?? const {}),
        ),
      );
    } on Object {
      return const StoredAppState();
    }
  }

  Future<void> save({
    required GameSession session,
    required PlayerStats stats,
    required AppSettings settings,
  }) => _preferences.setString(
    _stateKey,
    jsonEncode({
      'version': 1,
      'session': session.toJson(),
      'stats': stats.toJson(),
      'settings': settings.toJson(),
    }),
  );
}
