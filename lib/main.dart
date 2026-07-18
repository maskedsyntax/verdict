import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:verdict/app/verdict_app.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/core/services/supabase_config.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/leaderboard/supabase_leaderboard_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    WordRepository.load(rootBundle),
  ]);
  final preferences = results[0] as SharedPreferences;
  final words = results[1] as WordRepository;
  const supabaseConfig = SupabaseConfig.fromEnvironment();
  SupabaseLeaderboardServices? onlineServices;
  if (supabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: supabaseConfig.url,
      publishableKey: supabaseConfig.publishableKey,
    );
    onlineServices = SupabaseLeaderboardServices(Supabase.instance.client);
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ProviderScope(
      overrides: [
        appStorageProvider.overrideWithValue(AppStorage(preferences)),
        wordRepositoryProvider.overrideWithValue(words),
        if (onlineServices != null) ...[
          leaderboardRepositoryProvider.overrideWithValue(onlineServices),
          authServiceProvider.overrideWithValue(onlineServices),
          onlineServicesEnabledProvider.overrideWithValue(true),
        ],
      ],
      child: const VerdictApp(),
    ),
  );
}
