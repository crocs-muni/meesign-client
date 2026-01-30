import 'dart:io';

import 'package:args/args.dart';

class AppArgParser {
  AppArgParser({required this.args});
  final List<String> args;
  late final ArgResults _results;

  ArgResults initParser() {
    final parser = ArgParser()
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
      );

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
