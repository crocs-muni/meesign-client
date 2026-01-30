import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_client/app/widget/tabbed_scaffold.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/about_page.dart';
import 'package:meesign_client/pages/new_group_page.dart';
import 'package:meesign_client/pages/qr_reader_page.dart';
import 'package:meesign_client/pages/register_page.dart';
import 'package:meesign_client/routes.dart';
import 'package:meesign_client/theme.dart';
import 'package:meesign_client/util/app_arg_parser.dart';
import 'package:meesign_client/util/app_dir_getter.dart';
import 'package:meesign_client/util/error_logger.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  // Init error logger
  ErrorLogger().initLogger();

  // Parse command line arguments
  final argResults = AppArgParser(args: args).initParser();

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
        prefillHost: argResults['host'] as String?,
        prefillName: argResults['name'] as String?,
      ),
    ),
  );
}

Future<void> _prepareWindowManager() async {
  const double minWidth = 600;
  const double minHeight = 800;

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(minWidth, minHeight));

    final currentSize = await WindowManager.instance.getSize();
    if (currentSize.width < minWidth || currentSize.height < minHeight) {
      await WindowManager.instance.setSize(const Size(minWidth, minHeight));
    }

    WindowManager.instance.center();
    await windowManager.setPreventClose(true);
  }
}

class MeeSignClient extends StatefulWidget {
  const MeeSignClient({
    super.key,
    this.prefillHost,
    this.prefillName,
  });
  final String? prefillHost;
  final String? prefillName;

  @override
  State<MeeSignClient> createState() => _MeeSignClientState();
}

class _MeeSignClientState extends State<MeeSignClient> with WindowListener {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    const defaultHost = 'meesign.crocs.fi.muni.cz';
    configureSystemStyle();

    final container = context.read<AppContainer>();

    final settingsController = container.settingsController;

    return StreamBuilder(
      stream: settingsController.settingsStream,
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final settings = settingsSnapshot.data!;

        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'MeeSign',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          initialRoute: Routes.init,
          routes: {
            Routes.home: (_) => const TabbedScaffold(),
            Routes.newGroup: (_) => const NewGroupPage(),
            Routes.newGroupQr: (_) => const QrReaderPage(),
            Routes.about: (_) => const AboutPage(),
            Routes.init: (_) => RegisterPage(
                  prefillHost: widget.prefillHost ?? defaultHost,
                  prefillName: widget.prefillName ?? '',
                ),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: settingsController.getCurrentLanguageLocale(),
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

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final container = context.read<AppContainer>();
    final settingsController = container.settingsController;

    // Check if user previously chose "don't ask again"
    final dontAskAgain =
        settingsController.currentSettings.closeWithoutConfirmation;

    if (dontAskAgain) {
      await windowManager.destroy();
      return;
    }

    const yesKey = 'yes';
    const noKey = 'no';
    const yesDontAskKey = 'yesDontAsk';

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.confirmQuitTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(yesDontAskKey),
              child: Text(localizations.confirmQuitYesDontAsk),
            ),
            const SizedBox(
              width: 50,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(noKey),
              child: Text(localizations.no),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(yesKey),
              child: Text(localizations.yes),
            ),
          ],
        );
      },
    );

    if (result == yesKey || result == yesDontAskKey) {
      if (result == yesDontAskKey) {
        settingsController.updateCloseWithoutConfirmation(
          closeWithoutConfirmation: true,
        );
      }
      await windowManager.destroy();
    }
  }
}
