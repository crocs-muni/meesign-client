import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'app_container.dart';
import 'routes.dart';
import 'sync.dart';
import 'theme.dart';
import 'ui/card_reader_page.dart';
import 'ui/home_page.dart';
import 'ui/new_group_page.dart';
import 'ui/qr_identity_page.dart';
import 'ui/qr_reader_page.dart';
import 'ui/registration_page.dart';
import 'ui/search_peer_page.dart';

void printUsage(ArgParser parser, IOSink sink) {
  sink.writeln('Usage:');
  sink.writeln(parser.usage);
}

void main(List<String> args) async {
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

  final tmp = await getTemporaryDirectory();
  final unique = Random().nextInt(1 << 32);
  final tmpName = path_pkg.join(tmp.path, 'meesign_client-$unique');
  final appDir = Directory(tmpName);

  runApp(
    Provider(
      create: (_) => AppContainer(
        appDirectory: appDir,
      ),
      child: Provider(
        create: (_) => Sync(),
        child: MyApp(
          prefillHost: results?['host'],
          prefillName: results?['name'],
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? prefillHost;
  final String? prefillName;

  const MyApp({
    Key? key,
    this.prefillHost,
    this.prefillName,
  }) : super(key: key);

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
      initialRoute: Routes.registration,
      routes: {
        Routes.home: (_) => const HomePage(),
        Routes.newGroup: (_) => const NewGroupPage(),
        Routes.newGroupSearch: (_) => const SearchPeerPage(),
        Routes.newGroupCard: (_) => const AddCardPage(),
        Routes.newGroupQr: (_) => const QrReaderPage(),
        Routes.qrIdentity: (_) => const QrIdentityPage(),
        Routes.registration: (_) => RegistrationPage(
              prefillHost: prefillHost ?? 'meesign.crocs.fi.muni.cz',
              prefillName: prefillName ?? '',
            ),
      },
    );
  }
}
