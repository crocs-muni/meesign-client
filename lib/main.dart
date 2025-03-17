import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app_container.dart';
import 'pages/register_page.dart';
import 'routes.dart';
import 'services/settings_controller.dart';
import 'theme.dart';
import 'pages/about_page.dart';
import 'app/widget/tabbed_scaffold.dart';
import 'pages/new_group_page.dart';
import 'pages/qr_reader_page.dart';
import 'pages/search_peer_page.dart';
import 'util/app_arg_parser.dart';
import 'util/app_dir_getter.dart';
import 'util/error_logger.dart';

void main(List<String> args) async {
  // Init error logger
  ErrorLogger().initLogger();

  // Parse command line arguments
  final ArgResults argResults = AppArgParser(args: args).initParser();

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Prepare window manager
  await _prepareWindowManager();

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

Future<void> _prepareWindowManager() async {
  const double minWidth = 500;
  const double minHeight = 600;

  await windowManager.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowManager.instance.setMinimumSize(const Size(minWidth, minHeight));
  }
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

    final AppContainer container = context.read<AppContainer>();

    final SettingsController settingsController = container.settingsController;

    return StreamBuilder(
      stream: settingsController.settingsStream,
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        final settings = settingsSnapshot.data!;

        return MaterialApp(
          title: 'MeeSign',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          initialRoute: Routes.init,
          routes: {
            Routes.home: (_) => const TabbedScaffold(),
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
