import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict/features/game/game_controller.dart';
import 'package:verdict/features/results/share_result.dart';
import 'package:verdict_engine/verdict_engine.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({required this.state, required this.onClose, super.key});

  final GameViewState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final won = state.session.status == GameStatus.won;
    return ColoredBox(
      color: VerdictPalette.ink.withValues(alpha: 0.58),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 25, 24),
            child: BrutalBox(
              color: won ? VerdictPalette.green : VerdictPalette.pink,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          won ? 'VERDICT: SOLVED' : 'VERDICT: CLOSED',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close results',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TODAY\'S WORD',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    state.session.targets.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _ResultStat(
                        label: 'GUESSES',
                        value: won ? '${state.session.guesses.length}' : 'X',
                      ),
                      _ResultStat(
                        label: 'STREAK',
                        value: '${state.stats.currentStreak}',
                      ),
                      _ResultStat(
                        label: 'WIN %',
                        value: '${state.stats.winPercentage}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  BrutalButton(
                    label: 'SHARE RESULT',
                    icon: Icons.ios_share,
                    color: VerdictPalette.blue,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text: formatShareResult(
                            session: state.session,
                            number: state.puzzle.number,
                          ),
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Spoiler-free result copied.'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nextPuzzleText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _nextPuzzleText() {
    final now = DateTime.now().toUtc();
    final next = DateTime.utc(now.year, now.month, now.day + 1);
    final remaining = next.difference(now);
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    return 'NEXT VERDICT IN $hours:$minutes UTC';
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}
