import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verdict/core/words/word_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads licensed five-letter word assets', () async {
    final words = await WordRepository.load(rootBundle);

    expect(words.answers.length, greaterThan(3000));
    expect(words.validGuesses.length, greaterThan(8000));
    expect(words.answers.every(words.validGuesses.contains), isTrue);
    expect(words.validGuesses.every((word) => word.length == 5), isTrue);
  });
}
