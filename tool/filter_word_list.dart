import 'dart:io';
import 'dart:math';

void main(List<String> arguments) {
  if (arguments.length < 2 || arguments.length > 3) {
    stderr.writeln(
      'Usage: dart run tool/filter_word_list.dart INPUT OUTPUT [--shuffle]',
    );
    exitCode = 64;
    return;
  }

  final validWord = RegExp(r'^[a-z]{5}$');
  final words = File(
    arguments[0],
  ).readAsLinesSync().where(validWord.hasMatch).toSet().toList()..sort();
  if (arguments.length == 3 && arguments[2] == '--shuffle') {
    words.shuffle(Random(0x56455244));
  }
  File(arguments[1]).writeAsStringSync('${words.join('\n')}\n');
  stdout.writeln('Wrote ${words.length} words to ${arguments[1]}');
}
