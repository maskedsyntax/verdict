import 'package:flutter/material.dart';
import 'package:verdict/app/brutal_widgets.dart';
import 'package:verdict/app/verdict_theme.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 21, 20),
      child: BrutalBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'HOW TO PLAY',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close help',
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Deliver the daily verdict in six guesses. Every guess must be a five-letter word.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const _Example(
              color: VerdictPalette.green,
              letter: 'V',
              text: 'V is in the right spot.',
            ),
            const _Example(
              color: VerdictPalette.yellow,
              letter: 'E',
              text: 'E is in the word, but elsewhere.',
            ),
            const _Example(
              color: VerdictPalette.gray,
              letter: 'R',
              text: 'R is not in the word.',
            ),
            const SizedBox(height: 18),
            const Text(
              'A new puzzle arrives at midnight UTC. Your stats and streak stay on this device.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Example extends StatelessWidget {
  const _Example({
    required this.color,
    required this.letter,
    required this.text,
  });

  final Color color;
  final String letter;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: VerdictPalette.ink, width: 3),
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
