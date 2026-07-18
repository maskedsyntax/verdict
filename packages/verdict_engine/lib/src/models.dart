enum GameMode { classic, blitz, vault, twin, shift }

enum LetterGrade { miss, near, hit }

enum GameStatus { active, won, lost }

enum SubmissionError { invalidLength, unknownWord, gameOver, lockedLetter }

class GameConfig {
  const GameConfig({
    required this.mode,
    required this.wordLength,
    required this.maxGuesses,
    this.targetCount = 1,
    this.lockMissedKeys = false,
    this.timeLimitSeconds,
    this.scoreMultiplier = 1,
  }) : assert(wordLength > 0),
       assert(maxGuesses > 0),
       assert(targetCount > 0);

  const GameConfig.classic()
    : this(mode: GameMode.classic, wordLength: 5, maxGuesses: 6);

  const GameConfig.blitz()
    : this(
        mode: GameMode.blitz,
        wordLength: 5,
        maxGuesses: 6,
        timeLimitSeconds: 60,
        scoreMultiplier: 2,
      );

  const GameConfig.vault()
    : this(
        mode: GameMode.vault,
        wordLength: 5,
        maxGuesses: 4,
        lockMissedKeys: true,
        scoreMultiplier: 2,
      );

  const GameConfig.twin()
    : this(
        mode: GameMode.twin,
        wordLength: 5,
        maxGuesses: 7,
        targetCount: 2,
        scoreMultiplier: 2,
      );

  factory GameConfig.shift(int wordLength) {
    if (wordLength < 4 || wordLength > 7) {
      throw ArgumentError.value(wordLength, 'wordLength', 'must be 4 to 7');
    }
    return GameConfig(
      mode: GameMode.shift,
      wordLength: wordLength,
      maxGuesses: wordLength + 1,
      scoreMultiplier: 2,
    );
  }

  final GameMode mode;
  final int wordLength;
  final int maxGuesses;
  final int targetCount;
  final bool lockMissedKeys;
  final int? timeLimitSeconds;
  final int scoreMultiplier;

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'wordLength': wordLength,
    'maxGuesses': maxGuesses,
    'targetCount': targetCount,
    'lockMissedKeys': lockMissedKeys,
    'timeLimitSeconds': timeLimitSeconds,
    'scoreMultiplier': scoreMultiplier,
  };

  factory GameConfig.fromJson(Map<String, Object?> json) => GameConfig(
    mode: GameMode.values.byName(json['mode']! as String),
    wordLength: json['wordLength']! as int,
    maxGuesses: json['maxGuesses']! as int,
    targetCount: json['targetCount']! as int,
    lockMissedKeys: json['lockMissedKeys']! as bool,
    timeLimitSeconds: json['timeLimitSeconds'] as int?,
    scoreMultiplier: json['scoreMultiplier']! as int,
  );
}

class SubmissionException implements Exception {
  const SubmissionException(this.error, [this.letter]);

  final SubmissionError error;
  final String? letter;

  @override
  String toString() => 'SubmissionException(${error.name}, $letter)';
}
