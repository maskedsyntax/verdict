import 'package:flutter/material.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict/features/stats/player_stats.dart';

class StatsSheet extends StatelessWidget {
  const StatsSheet({
    required this.stats,
    required this.onLeaderboard,
    super.key,
  });

  final PlayerStats stats;
  final VoidCallback onLeaderboard;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 21, 20),
      child: BrutalBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'THE RECORD',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close stats',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(label: 'PLAYED', value: '${stats.gamesPlayed}'),
                _Stat(label: 'WIN %', value: '${stats.winPercentage}'),
                _Stat(label: 'STREAK', value: '${stats.currentStreak}'),
                _Stat(label: 'BEST', value: '${stats.maxStreak}'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'GUESS DISTRIBUTION',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            for (var guess = 1; guess <= 6; guess++)
              _DistributionRow(
                guess: guess,
                count: stats.guessDistribution[guess] ?? 0,
                maximum: stats.guessDistribution.values.fold(
                  1,
                  (largest, value) => value > largest ? value : largest,
                ),
              ),
            const SizedBox(height: 18),
            BrutalButton(
              label: 'GLOBAL BOARD',
              icon: Icons.emoji_events_outlined,
              color: VerdictPalette.yellow,
              onPressed: onLeaderboard,
            ),
          ],
        ),
      ),
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

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

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.guess,
    required this.count,
    required this.maximum,
  });

  final int guess;
  final int count;
  final int maximum;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(
          width: 24,
          child: Text('$guess', style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: count == 0 ? 0.08 : count / maximum,
            child: Container(
              height: 25,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: count == 0 ? VerdictPalette.gray : VerdictPalette.blue,
                border: Border.all(color: VerdictPalette.ink, width: 2),
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
