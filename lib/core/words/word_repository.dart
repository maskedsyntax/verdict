import 'package:flutter/services.dart';

class WordRepository {
  const WordRepository({required this.answers, required this.validGuesses});

  final List<String> answers;
  final Set<String> validGuesses;

  static Future<WordRepository> load(AssetBundle bundle) async {
    final files = await Future.wait([
      bundle.loadString('assets/words/answers.txt'),
      bundle.loadString('assets/words/valid_words.txt'),
    ]);
    final answers = _lines(files[0]).toList(growable: false);
    final validGuesses = {..._lines(files[1]), ...answers};
    if (answers.isEmpty || validGuesses.isEmpty) {
      throw StateError('Word assets are empty.');
    }
    return WordRepository(
      answers: answers,
      validGuesses: Set.unmodifiable(validGuesses),
    );
  }

  static Iterable<String> _lines(String contents) => contents
      .split('\n')
      .map((word) => word.trim())
      .where((word) => RegExp(r'^[a-z]{5}$').hasMatch(word));
}
