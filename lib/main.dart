import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
import 'package:mpc_demo/widget/new_group_page.dart';
import 'package:mpc_demo/widget/search_peer_page.dart';
import 'package:provider/provider.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/new_group': (context) => const NewGroupPage(),
        '/new_group/search': (context) => const SearchPeerPage(),
      },
    );
  }
}
