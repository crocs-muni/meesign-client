import 'dart:io';

import 'package:args/args.dart';

class AppArgParser {
  final List<String> args;
  late final ArgResults _results;

  AppArgParser({required this.args});

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
      if (_results['help']) printUsage(parser, stdout);
    } on ArgParserException catch (e) {
      stderr.writeln(e.message);
      printUsage(parser, stderr);
    }

    return _results;
  }

  void printUsage(ArgParser parser, IOSink sink) {
    sink.writeln('Usage:');
    sink.writeln(parser.usage);
  }
}
