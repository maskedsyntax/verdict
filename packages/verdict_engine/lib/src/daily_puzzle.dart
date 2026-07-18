class DailyPuzzle {
  const DailyPuzzle({
    required this.id,
    required this.number,
    required this.utcDate,
    required this.answers,
  });

  final String id;
  final int number;
  final DateTime utcDate;
  final List<String> answers;
}

class DailyPuzzleResolver {
  DailyPuzzleResolver({required List<String> answers, DateTime? epoch})
    : _answers = List.unmodifiable(answers),
      epoch = _dateOnly(epoch ?? DateTime.utc(2026)) {
    if (answers.isEmpty) {
      throw ArgumentError('At least one answer is required.');
    }
  }

  final List<String> _answers;
  final DateTime epoch;

  DailyPuzzle resolve(DateTime instant, {int targetCount = 1}) {
    if (targetCount < 1 || targetCount > _answers.length) {
      throw ArgumentError.value(targetCount, 'targetCount');
    }
    final date = _dateOnly(instant.toUtc());
    final dayOffset = date.difference(epoch).inDays;
    if (dayOffset < 0) throw StateError('No puzzle exists before the epoch.');
    final puzzleAnswers = List.generate(
      targetCount,
      (index) => _answers[(dayOffset * targetCount + index) % _answers.length],
    );
    final number = dayOffset + 1;
    return DailyPuzzle(
      id: 'classic-${_dateKey(date)}',
      number: number,
      utcDate: date,
      answers: List.unmodifiable(puzzleAnswers),
    );
  }

  static String dateKey(DateTime instant) =>
      _dateKey(_dateOnly(instant.toUtc()));

  static DateTime _dateOnly(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
