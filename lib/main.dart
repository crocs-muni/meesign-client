import 'package:flutter/material.dart';
import 'package:meesign_client/mpc_model.dart';
import 'package:meesign_client/widget/card_reader_page.dart';
import 'package:meesign_client/widget/new_group_page.dart';
import 'package:meesign_client/widget/qr_identity_page.dart';
import 'package:meesign_client/widget/qr_reader_page.dart';
import 'package:meesign_client/widget/registration_page.dart';
import 'package:meesign_client/widget/search_peer_page.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme.dart';
import 'widget/home_page.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => MpcModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Routes.registration,
      routes: {
        Routes.home: (_) => const HomePage(),
        Routes.newGroup: (_) => const NewGroupPage(),
        Routes.newGroupSearch: (_) => const SearchPeerPage(),
        Routes.newGroupCard: (_) => const CardReaderPage(),
        Routes.newGroupQr: (_) => const QrReaderPage(),
        Routes.qrIdentity: (_) => const QrIdentityPage(),
        Routes.registration: (_) => const RegistrationPage(),
      },
    );
  }
}
