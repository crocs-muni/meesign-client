import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'model/mpc_model.dart';
import 'routes.dart';
import 'theme.dart';
import 'widget/card_reader_page.dart';
import 'widget/home_page.dart';
import 'widget/new_group_page.dart';
import 'widget/qr_identity_page.dart';
import 'widget/qr_reader_page.dart';
import 'widget/registration_page.dart';
import 'widget/search_peer_page.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    MpcModel.log(details.toString(minLevel: DiagnosticLevel.debug));
  };
  runZonedGuarded(() {
    runApp(ChangeNotifierProvider(
      create: (context) => MpcModel(),
      child: const MyApp(),
    ));
  }, ((error, stack) {
    MpcModel.log(error.toString() + '**stacktrace**\n' + stack.toString());
  }));

  runApp(ChangeNotifierProvider(
    create: (context) => MpcModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Routes.registration: (_) => const RegistrationPage(),
      },
    );
  }
}
