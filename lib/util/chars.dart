import 'package:characters/characters.dart';

const asciiPunctuationChars = '!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';

extension Initials on String {
  String get initials => trimLeft().characters.take(1).toString().toUpperCase();
}

extension SplitByLength on String {
  Iterable<String> splitByLength(int length) {
    assert(length > 1);
    int count = (this.length + 1) ~/ length;
    return Iterable.generate(
        count, (int i) => substring(i * length, (i + 1) * length));
  }
}

extension Capitalize on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
