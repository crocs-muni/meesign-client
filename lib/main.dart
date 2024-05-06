import 'dart:io';
import 'dart:ui';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'app_container.dart';
import 'routes.dart';
import 'theme.dart';
import 'ui/home_page.dart';
import 'ui/init_page.dart';
import 'ui/new_group_page.dart';
import 'ui/qr_reader_page.dart';
import 'ui/search_peer_page.dart';

void printUsage(ArgParser parser, IOSink sink) {
  sink.writeln('Usage:');
  sink.writeln(parser.usage);
}

Future<Directory> getAppDir() async {
  if (Platform.isIOS || Platform.isMacOS) {
    return getLibraryDirectory();
  }
  if (Platform.isAndroid) {
    return getApplicationSupportDirectory();
  }
  final path = path_pkg.join(
    path_pkg.dirname(Platform.resolvedExecutable),
    'app',
  );
  return Directory(path);
}

void main(List<String> args) async {
  Logger.root.level = Level.WARNING;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Logger.root.severe(details.toString(), details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.root.severe(error.toString(), error, stack);
    return false;
  };

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

  ArgResults? results;
  try {
    results = parser.parse(args);
    if (results['help']) printUsage(parser, stdout);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    printUsage(parser, stderr);
  }

  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getAppDir();

  runApp(
    Provider<AppContainer>(
      create: (_) => AppContainer(
        appDirectory: appDir,
      ),
      dispose: (_, appContainer) => appContainer.dispose(),
      child: MyApp(
        prefillHost: results?['host'],
        prefillName: results?['name'],
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? prefillHost;
  final String? prefillName;

  const MyApp({
    super.key,
    this.prefillHost,
    this.prefillName,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: 'MeeSign',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: Routes.init,
      routes: {
        Routes.home: (_) => const HomePage(),
        Routes.newGroup: (_) => const NewGroupPage(),
        Routes.newGroupSearch: (_) => const SearchPeerPage(),
        Routes.newGroupQr: (_) => const QrReaderPage(),
        Routes.init: (_) => InitPage(
              prefillHost: prefillHost ?? 'meesign.crocs.fi.muni.cz',
              prefillName: prefillName ?? '',
            ),
      },
    );
  }
}
