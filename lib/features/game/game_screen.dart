import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict/core/services/service_providers.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/game/game_grid.dart';
import 'package:verdict/features/game/game_keyboard.dart';
import 'package:verdict/features/game/help_sheet.dart';
import 'package:verdict/features/leaderboard/leaderboard_sheet.dart';
import 'package:verdict/features/results/result_panel.dart';
import 'package:verdict/features/settings/settings_sheet.dart';
import 'package:verdict/features/stats/stats_sheet.dart';
import 'package:verdict_engine/verdict_engine.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _focusNode = FocusNode(debugLabel: 'game keyboard');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final adService = ref.watch(adServiceProvider);
    final hintText = game.revealedHints.isEmpty
        ? null
        : 'HINT: WORD CONTAINS ${game.revealedHints.map((letter) => letter.toUpperCase()).join(', ')}';
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          controller.removeLetter();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          controller.submit();
          return KeyEventResult.handled;
        }
        final label = event.logicalKey.keyLabel.toLowerCase();
        if (RegExp(r'^[a-z]$').hasMatch(label)) {
          controller.addLetter(label);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _Header(
                    puzzleNumber: game.puzzle.number,
                    onHelp: () => _showSheet(context, const HelpSheet()),
                    onStats: () => _showSheet(
                      context,
                      StatsSheet(
                        stats: game.stats,
                        onLeaderboard: () => _openLeaderboard(context, game),
                      ),
                    ),
                    onSettings: () => _showSheet(
                      context,
                      SettingsSheet(
                        settings: game.settings,
                        onHighContrastChanged: controller.setHighContrast,
                        onStreakReminderChanged: controller.setStreakReminder,
                        onAdPrivacy: adService.isEnabled
                            ? () => _showAdPrivacy(context)
                            : null,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: game.errorMessage == null && hintText == null
                        ? const SizedBox(height: 38)
                        : Padding(
                            key: ValueKey(game.errorMessage ?? hintText),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              width: double.infinity,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: game.errorMessage == null
                                    ? VerdictPalette.yellow
                                    : VerdictPalette.pink,
                                border: Border.all(
                                  color: VerdictPalette.ink,
                                  width: 2.5,
                                ),
                              ),
                              child: Text(
                                game.errorMessage ?? hintText!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(game.errorMessage),
                        tween: Tween(
                          begin: 0,
                          end: game.errorMessage == null ? 0 : 1,
                        ),
                        duration: const Duration(milliseconds: 320),
                        builder: (context, progress, child) =>
                            Transform.translate(
                              offset: Offset(
                                game.errorMessage == null
                                    ? 0
                                    : 7 *
                                          (progress < 0.25
                                              ? 1
                                              : progress < 0.5
                                              ? -1
                                              : progress < 0.75
                                              ? 1
                                              : 0),
                                0,
                              ),
                              child: child,
                            ),
                        child: GameGrid(
                          session: game.session,
                          draft: game.draft,
                          highContrast: game.settings.highContrast,
                        ),
                      ),
                    ),
                  ),
                  if (game.session.status == GameStatus.active &&
                      adService.isEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 2, 16, 3),
                      child: SizedBox(
                        height: 38,
                        child: BrutalButton(
                          label: 'WATCH FOR A LETTER HINT',
                          icon: Icons.lightbulb_outline,
                          color: VerdictPalette.yellow,
                          onPressed: () => _showRewardedHint(context),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 190,
                    child: GameKeyboard(
                      grades: game.session.keyboardGrades,
                      highContrast: game.settings.highContrast,
                      onLetter: controller.addLetter,
                      onDelete: controller.removeLetter,
                      onEnter: controller.submit,
                    ),
                  ),
                ],
              ),
              if (game.resultVisible)
                Positioned.fill(
                  child: ResultPanel(
                    state: game,
                    onClose: controller.closeResult,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSheet(BuildContext context, Widget child) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => child,
      );

  Future<void> _openLeaderboard(
    BuildContext context,
    GameViewState game,
  ) async {
    Navigator.pop(context);
    await Future<void>.delayed(Duration.zero);
    if (mounted) {
      await _showSheet(this.context, LeaderboardSheet(game: game));
    }
  }

  Future<void> _showRewardedHint(BuildContext context) async {
    final earned = await ref.read(adServiceProvider).showRewardedHint(() async {
      await ref.read(gameControllerProvider.notifier).revealHint();
    });
    if (!earned && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hint earned. Try again shortly.')),
      );
    }
  }

  Future<void> _showAdPrivacy(BuildContext context) async {
    final shown = await ref.read(adServiceProvider).showPrivacyOptions();
    if (!shown && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No additional privacy form is required here.'),
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.puzzleNumber,
    required this.onHelp,
    required this.onStats,
    required this.onSettings,
  });

  final int puzzleNumber;
  final VoidCallback onHelp;
  final VoidCallback onStats;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 18, 8),
    child: Row(
      children: [
        BrutalIconButton(
          icon: Icons.help_outline,
          tooltip: 'How to play',
          onPressed: onHelp,
          color: VerdictPalette.yellow,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text(
                'VERDICT',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 31,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'DAILY CASE #$puzzleNumber',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        BrutalIconButton(
          icon: Icons.bar_chart,
          tooltip: 'Statistics',
          onPressed: onStats,
          color: VerdictPalette.blue,
        ),
        const SizedBox(width: 10),
        BrutalIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: onSettings,
        ),
      ],
    ),
  );
}
