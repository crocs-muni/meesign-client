import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
import 'package:mpc_demo/widget/card_reader_page.dart';
import 'package:mpc_demo/widget/new_group_page.dart';
import 'package:mpc_demo/widget/qr_identity_page.dart';
import 'package:mpc_demo/widget/qr_reader_page.dart';
import 'package:mpc_demo/widget/registration_page.dart';
import 'package:mpc_demo/widget/search_peer_page.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
