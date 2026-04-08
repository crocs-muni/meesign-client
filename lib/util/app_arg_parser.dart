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
      if (_results['help'] as bool) _printUsage(parser);
    } on ArgParserException catch (e) {
      // needed for CLI output without Flutter logger
      // ignore: avoid_print
      print(e.message);
      _printUsage(parser);
    }

    return _results;
  }

  void _printUsage(ArgParser parser) {
    // needed for CLI output without Flutter logger
    // ignore: avoid_print
    print('Usage:\n${parser.usage}');
  }
}
