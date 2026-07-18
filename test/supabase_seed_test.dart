import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('server puzzle seed follows the bundled answer schedule', () {
    final answers = File('assets/words/answers.txt').readAsLinesSync();
    final migration = File(
      'supabase/migrations/202607190002_word_seed.sql',
    ).readAsStringSync();

    expect(
      RegExp(r"\('classic-\d{4}-\d{2}-\d{2}'").allMatches(migration).length,
      answers.length,
    );
    expect(
      migration,
      contains(
        "('classic-2026-01-01', 'classic', '2026-01-01', 1, '${answers.first}'",
      ),
    );
    expect(migration, contains("'${answers.last}', 6, 1)"));
  });
}
