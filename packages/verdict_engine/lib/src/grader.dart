import 'models.dart';

List<LetterGrade> gradeGuess(String answer, String guess) {
  if (answer.length != guess.length) {
    throw ArgumentError('Answer and guess must have the same length.');
  }

  final grades = List<LetterGrade>.filled(guess.length, LetterGrade.miss);
  final remaining = <String, int>{};

  for (var index = 0; index < answer.length; index++) {
    if (answer[index] == guess[index]) {
      grades[index] = LetterGrade.hit;
    } else {
      remaining.update(answer[index], (count) => count + 1, ifAbsent: () => 1);
    }
  }

  for (var index = 0; index < guess.length; index++) {
    if (grades[index] == LetterGrade.hit) continue;
    final count = remaining[guess[index]] ?? 0;
    if (count > 0) {
      grades[index] = LetterGrade.near;
      remaining[guess[index]] = count - 1;
    }
  }

  return List.unmodifiable(grades);
}

Map<String, LetterGrade> mergeKeyboardGrades(
  Iterable<String> guesses,
  Iterable<List<List<LetterGrade>>> evaluations,
) {
  final merged = <String, LetterGrade>{};
  final guessList = guesses.toList();
  final evaluationList = evaluations.toList();

  for (var guessIndex = 0; guessIndex < guessList.length; guessIndex++) {
    final guess = guessList[guessIndex];
    for (final targetGrades in evaluationList[guessIndex]) {
      for (var letterIndex = 0; letterIndex < guess.length; letterIndex++) {
        final letter = guess[letterIndex];
        final grade = targetGrades[letterIndex];
        if (grade.index > (merged[letter]?.index ?? -1)) merged[letter] = grade;
      }
    }
  }
  return Map.unmodifiable(merged);
}
