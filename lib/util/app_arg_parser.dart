import 'dart:io';

import 'package:args/args.dart';

class AppArgParser {
  AppArgParser({required this.args});
  final List<String> args;
  late final ArgResults _results;

  static ArgParser buildParser() {
    return ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'display usage information',
        negatable: false,
      )
      ..addOption(
        'host',
        help: 'address of the server',
      )
      ..addOption(
        'name',
        help: 'name of the user',
      )
      ..addOption(
        'app-dir',
        help: 'override application support directory '
            '(database, keys, files; default: platform-specific)',
      )
      ..addOption(
        'temp-dir',
        help: 'override temporary directory '
            '(short-lived files; default: platform-specific)',
      )
      ..addOption(
        'downloads-dir',
        help: 'override downloads directory '
            '(user-visible received files; default: platform-specific)',
      )
      ..addOption(
        'documents-dir',
        help: 'override documents directory '
            '(user-generated files; default: platform-specific)',
      )
      ..addOption(
        'cache-dir',
        help: 'override cache directory '
            '(re-downloadable data; default: platform-specific)',
      );
  }

  ArgResults initParser() {
    final parser = buildParser();

    try {
      _results = parser.parse(args);
      if (_results['help'] as bool) printUsage(parser, stdout);
    } on ArgParserException catch (e) {
      stderr.writeln(e.message);
      printUsage(parser, stderr);
    }

    return _results;
  }

  void printUsage(ArgParser parser, IOSink sink) {
    sink
      ..writeln('Usage:')
      ..writeln(parser.usage);
  }
}
