import 'grader.dart';
import 'models.dart';

class GameSession {
  GameSession._({
    required this.puzzleId,
    required this.config,
    required List<String> targets,
    required List<String> guesses,
    required List<List<List<LetterGrade>>> evaluations,
    required List<int?> solvedAtGuess,
  }) : targets = List.unmodifiable(targets),
       guesses = List.unmodifiable(guesses),
       evaluations = List<List<List<LetterGrade>>>.unmodifiable(
         evaluations.map(
           (evaluation) => List<List<LetterGrade>>.unmodifiable(
             evaluation.map((grades) => List<LetterGrade>.unmodifiable(grades)),
           ),
         ),
       ),
       solvedAtGuess = List.unmodifiable(solvedAtGuess) {
    if (targets.length != config.targetCount ||
        targets.any((word) => word.length != config.wordLength)) {
      throw ArgumentError('Targets do not match the game configuration.');
    }
  }

  factory GameSession.start({
    required String puzzleId,
    required GameConfig config,
    required List<String> targets,
  }) => GameSession._(
    puzzleId: puzzleId,
    config: config,
    targets: targets.map((word) => word.toLowerCase()).toList(),
    guesses: const [],
    evaluations: const [],
    solvedAtGuess: List<int?>.filled(targets.length, null),
  );

  final String puzzleId;
  final GameConfig config;
  final List<String> targets;
  final List<String> guesses;
  final List<List<List<LetterGrade>>> evaluations;
  final List<int?> solvedAtGuess;

  GameStatus get status {
    if (solvedAtGuess.every((guess) => guess != null)) return GameStatus.won;
    if (guesses.length >= config.maxGuesses) return GameStatus.lost;
    return GameStatus.active;
  }

  int get guessesRemaining => config.maxGuesses - guesses.length;

  Map<String, LetterGrade> get keyboardGrades =>
      mergeKeyboardGrades(guesses, evaluations);

  GameSession submit(String rawGuess, Set<String> validWords) {
    if (status != GameStatus.active) {
      throw const SubmissionException(SubmissionError.gameOver);
    }
    final guess = rawGuess.toLowerCase();
    if (guess.length != config.wordLength) {
      throw const SubmissionException(SubmissionError.invalidLength);
    }
    if (!validWords.contains(guess)) {
      throw const SubmissionException(SubmissionError.unknownWord);
    }
    if (config.lockMissedKeys) {
      for (final letter in guess.split('')) {
        if (keyboardGrades[letter] == LetterGrade.miss) {
          throw SubmissionException(SubmissionError.lockedLetter, letter);
        }
      }
    }

    final nextEvaluations = targets
        .map((target) => gradeGuess(target, guess))
        .toList();
    final nextSolved = solvedAtGuess.toList();
    for (var index = 0; index < targets.length; index++) {
      if (nextSolved[index] == null && guess == targets[index]) {
        nextSolved[index] = guesses.length + 1;
      }
    }
    return GameSession._(
      puzzleId: puzzleId,
      config: config,
      targets: targets,
      guesses: [...guesses, guess],
      evaluations: <List<List<LetterGrade>>>[...evaluations, nextEvaluations],
      solvedAtGuess: nextSolved,
    );
  }

  Map<String, Object?> toJson() => {
    'puzzleId': puzzleId,
    'config': config.toJson(),
    'targets': targets,
    'guesses': guesses,
    'evaluations': evaluations
        .map(
          (evaluation) => evaluation
              .map((grades) => grades.map((grade) => grade.name).toList())
              .toList(),
        )
        .toList(),
    'solvedAtGuess': solvedAtGuess,
  };

  factory GameSession.fromJson(Map<String, Object?> json) {
    final rawEvaluations = json['evaluations']! as List<Object?>;
    return GameSession._(
      puzzleId: json['puzzleId']! as String,
      config: GameConfig.fromJson(
        Map<String, Object?>.from(json['config']! as Map),
      ),
      targets: List<String>.from(json['targets']! as List),
      guesses: List<String>.from(json['guesses']! as List),
      evaluations: rawEvaluations.map((rawEvaluation) {
        final targetEvaluations = rawEvaluation! as List<Object?>;
        return targetEvaluations.map((rawGrades) {
          return (rawGrades! as List<Object?>)
              .map((grade) => LetterGrade.values.byName(grade! as String))
              .toList();
        }).toList();
      }).toList(),
      solvedAtGuess: (json['solvedAtGuess']! as List<Object?>)
          .map((value) => value as int?)
          .toList(),
    );
  }
}
