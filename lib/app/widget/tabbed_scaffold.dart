import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../view_model/app_view_model.dart';
import '../model/navigation_tab_model.dart';
import '../../app_container.dart';
import '../../widget/counter_badge.dart';
import '../../widget/fab_configurator.dart';
import '../../widget/main_app_bar.dart';
import '../../pages/challenge_sub_page.dart';
import '../../pages/decrypt_sub_page.dart';
import '../../pages/groups_sub_page.dart';
import '../../pages/signing_sub_page.dart';

class TabbedScaffold extends StatelessWidget {
  const TabbedScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppContainer>().session!;
    return ChangeNotifierProvider(
      create: (context) => AppViewModel(
        session.user,
        session.deviceRepository,
        session.groupRepository,
        session.fileRepository,
        session.challengeRepository,
        session.decryptRepository,
      ),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _index = 0;
  late List<NavigationTabModel> tabs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabs();
  }

  void _initializeTabs() {
    tabs = <NavigationTabModel>[
      NavigationTabModel(
        label: 'Signing',
        child: SigningSubPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nSignReqs,
          icon: Symbols.draw,
          fillIcon: _index == 0,
        ),
      ),
      NavigationTabModel(
        label: 'Challenge',
        child: ChallengeSubPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nChallengeReqs,
          icon: Symbols.quiz,
          fillIcon: _index == 1,
        ),
      ),
      NavigationTabModel(
        label: 'Decrypt',
        child: DecryptSubPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nDecryptReqs,
          icon: Symbols.key,
          fillIcon: _index == 2,
        ),
      ),
      NavigationTabModel(
        label: 'Groups',
        child: GroupsSubPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nGroupReqs,
          icon: Symbols.group,
          fillIcon: _index == 3,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildPageBody(),
      floatingActionButton:
          FabConfigurator(index: _index, buildContext: context),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  void _onItemTapped(int index) {
    if (_index == index) {
      // If the user taps the current tab again, pop to the root of that tab
      var navigatorKey = tabs[index].navigatorKey;
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _index = index;
      });
    }
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _onItemTapped,
      destinations: tabs.map<NavigationDestination>(
        (NavigationTabModel destination) {
          return NavigationDestination(
            icon: destination.icon,
            label: destination.label,
          );
        },
      ).toList(),
    );
  }

  Widget _buildCounterIcon(
      {required Stream<int> stream,
      required IconData icon,
      bool fillIcon = false}) {
    return CounterBadge(
      stream: stream,
      child: Icon(icon, fill: fillIcon ? 1 : 0),
    );
  }

  Widget _buildPageBody() {
    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: Colors.transparent,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: tabs[_index].child,
    );
  }
}
