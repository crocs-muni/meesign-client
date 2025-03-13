import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_container.dart';
import 'pages/register_page.dart';
import 'routes.dart';
import 'theme.dart';
import 'ui/about_page.dart';
import 'pages/home_page.dart';
import 'ui/new_group_page.dart';
import 'ui/qr_reader_page.dart';
import 'ui/search_peer_page.dart';
import 'util/app_arg_parser.dart';
import 'util/app_dir_getter.dart';
import 'util/error_logger.dart';

void main(List<String> args) async {
  // Init error logger
  ErrorLogger().initLogger();

  // Parse command line arguments
  final ArgResults argResults = AppArgParser(args: args).initParser();

  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await AppDirGetter.getAppDir();

  runApp(
    Provider<AppContainer>(
      create: (_) => AppContainer(
        appDirectory: appDir,
      ),
      dispose: (_, appContainer) => appContainer.dispose(),
      child: MeeSignClient(
        prefillHost: argResults['host'],
        prefillName: argResults['name'],
      ),
    ),
  );
}

class MeeSignClient extends StatelessWidget {
  final String? prefillHost;
  final String? prefillName;

  const MeeSignClient({
    super.key,
    this.prefillHost,
    this.prefillName,
  });

  @override
  Widget build(BuildContext context) {
    const String defaultHost = 'meesign.crocs.fi.muni.cz';
    configureSystemStyle();

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
        Routes.about: (_) => const AboutPage(),
        Routes.init: (_) => RegisterPage(
              prefillHost: prefillHost ?? defaultHost,
              prefillName: prefillName ?? '',
            ),
      },
    );
  }

  void configureSystemStyle() {
    // Configure system style like status bar color and navigation bar color
    // Applies to both Android and iOS
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }
}
