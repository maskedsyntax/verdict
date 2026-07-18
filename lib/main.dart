import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdict/app/verdict_app.dart';
import 'package:verdict/core/storage/app_storage.dart';
import 'package:verdict/core/words/word_repository.dart';
import 'package:verdict/features/game/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    WordRepository.load(rootBundle),
  ]);
  final preferences = results[0] as SharedPreferences;
  final words = results[1] as WordRepository;

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ProviderScope(
      overrides: [
        appStorageProvider.overrideWithValue(AppStorage(preferences)),
        wordRepositoryProvider.overrideWithValue(words),
      ],
      child: const VerdictApp(),
    ),
  );
}
