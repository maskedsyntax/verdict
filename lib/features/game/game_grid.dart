import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict_engine/verdict_engine.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({
    required this.session,
    required this.draft,
    required this.highContrast,
    super.key,
  });

  final GameSession session;
  final String draft;
  final bool highContrast;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = math.min(constraints.maxWidth, 350.0);
      final height = math.min(constraints.maxHeight, width * 1.22);
      return Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: List.generate(session.config.maxGuesses, (rowIndex) {
              final isSubmitted = rowIndex < session.guesses.length;
              final word = isSubmitted
                  ? session.guesses[rowIndex]
                  : rowIndex == session.guesses.length
                  ? draft
                  : '';
              final grades = isSubmitted
                  ? session.evaluations[rowIndex].first
                  : null;
              return Expanded(
                child: Row(
                  children: List.generate(session.config.wordLength, (column) {
                    final letter = column < word.length ? word[column] : '';
                    final grade = grades?[column];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: _LetterTile(
                          letter: letter,
                          grade: grade,
                          highContrast: highContrast,
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      );
    },
  );
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.grade,
    required this.highContrast,
  });

  final String letter;
  final LetterGrade? grade;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    Color colorFor(LetterGrade? visibleGrade) => switch (visibleGrade) {
      LetterGrade.hit =>
        highContrast ? const Color(0xFF00843D) : VerdictPalette.green,
      LetterGrade.near =>
        highContrast ? const Color(0xFFFFB000) : VerdictPalette.yellow,
      LetterGrade.miss =>
        highContrast ? const Color(0xFF444148) : VerdictPalette.gray,
      null => VerdictPalette.white,
    };
    final status = switch (grade) {
      LetterGrade.hit => 'correct position',
      LetterGrade.near => 'wrong position',
      LetterGrade.miss => 'not present',
      null => 'not submitted',
    };
    return Semantics(
      label: letter.isEmpty ? 'Empty tile' : '${letter.toUpperCase()}, $status',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: grade == null ? 0 : 1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        builder: (context, progress, child) {
          final visibleGrade = progress >= 0.5 ? grade : null;
          return Transform.scale(
            scaleY: (1 - progress * 2).abs().clamp(0.04, 1),
            child: Container(
              decoration: BoxDecoration(
                color: colorFor(visibleGrade),
                border: Border.all(color: VerdictPalette.ink, width: 3),
                boxShadow: visibleGrade == null
                    ? null
                    : const [
                        BoxShadow(
                          color: VerdictPalette.ink,
                          offset: Offset(2, 2),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: letter.isEmpty ? 0.8 : 1,
                duration: const Duration(milliseconds: 100),
                child: Text(
                  letter.toUpperCase(),
                  style: TextStyle(
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: visibleGrade == LetterGrade.miss
                        ? VerdictPalette.white
                        : VerdictPalette.ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
