import 'package:characters/characters.dart';

const asciiPunctuationChars = '!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';

extension Initials on String {
  String get initials => trimLeft().characters.first.toUpperCase();
}
