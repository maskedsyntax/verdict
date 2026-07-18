import 'package:flutter/material.dart';
import 'package:verdict/app/verdict_theme.dart';
import 'package:verdict_engine/verdict_engine.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    required this.grades,
    required this.onLetter,
    required this.onDelete,
    required this.onEnter,
    required this.highContrast,
    super.key,
  });

  static const _rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];

  final Map<String, LetterGrade> grades;
  final ValueChanged<String> onLetter;
  final VoidCallback onDelete;
  final VoidCallback onEnter;
  final bool highContrast;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(5, 4, 5, 8),
    child: Column(
      children: [
        for (var rowIndex = 0; rowIndex < _rows.length; rowIndex++)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (rowIndex == 2)
                  _Key(
                    label: 'ENTER',
                    semanticLabel: 'Submit guess',
                    flex: 2,
                    onTap: onEnter,
                    color: VerdictPalette.blue,
                  ),
                for (final letter in _rows[rowIndex].split(''))
                  _Key(
                    label: letter.toUpperCase(),
                    semanticLabel: letter.toUpperCase(),
                    grade: grades[letter],
                    highContrast: highContrast,
                    onTap: () => onLetter(letter),
                  ),
                if (rowIndex == 2)
                  _Key(
                    label: '⌫',
                    semanticLabel: 'Delete letter',
                    flex: 2,
                    onTap: onDelete,
                    color: VerdictPalette.pink,
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.flex = 1,
    this.grade,
    this.color,
    this.highContrast = false,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final int flex;
  final LetterGrade? grade;
  final Color? color;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final keyColor =
        color ??
        switch (grade) {
          LetterGrade.hit =>
            highContrast ? const Color(0xFF00843D) : VerdictPalette.green,
          LetterGrade.near =>
            highContrast ? const Color(0xFFFFB000) : VerdictPalette.yellow,
          LetterGrade.miss => const Color(0xFF77747D),
          null => VerdictPalette.white,
        };
    return Expanded(
      flex: flex,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: keyColor,
                  border: Border.all(color: VerdictPalette.ink, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: VerdictPalette.ink, offset: Offset(2, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: label.length > 1 ? 10 : 15,
                      fontWeight: FontWeight.w900,
                      color: grade == LetterGrade.miss
                          ? VerdictPalette.white
                          : VerdictPalette.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
