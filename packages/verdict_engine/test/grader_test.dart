import 'package:test/test.dart';
import 'package:verdict_engine/verdict_engine.dart';

void main() {
  test('grades exact, near, and absent letters', () {
    expect(gradeGuess('crane', 'cider'), [
      LetterGrade.hit,
      LetterGrade.miss,
      LetterGrade.miss,
      LetterGrade.near,
      LetterGrade.near,
    ]);
  });

  test('does not award a duplicate letter more than once', () {
    expect(gradeGuess('apple', 'allee'), [
      LetterGrade.hit,
      LetterGrade.near,
      LetterGrade.miss,
      LetterGrade.miss,
      LetterGrade.hit,
    ]);
  });

  test('keyboard keeps the most informative grade', () {
    final grades = mergeKeyboardGrades(
      ['cider', 'crane'],
      [
        [gradeGuess('crane', 'cider')],
        [gradeGuess('crane', 'crane')],
      ],
    );
    expect(grades['r'], LetterGrade.hit);
    expect(grades['i'], LetterGrade.miss);
  });
}
