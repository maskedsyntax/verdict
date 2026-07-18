import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/game/game_screen.dart';

class VerdictApp extends ConsumerWidget {
  const VerdictApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highContrast = ref.watch(
      gameControllerProvider.select((state) => state.settings.highContrast),
    );
    return MaterialApp(
      title: 'VERDICT',
      debugShowCheckedModeBanner: false,
      theme: verdictTheme(highContrast: highContrast),
      home: const GameScreen(),
    );
  }
}
