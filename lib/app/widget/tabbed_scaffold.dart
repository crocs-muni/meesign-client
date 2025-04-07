import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../pages/settings_page.dart';
import '../../ui_constants.dart';
import '../../util/layout_getter.dart';
import '../../view_model/app_view_model.dart';
import '../../widget/fluid_gradient.dart';
import '../model/navigation_tab_model.dart';
import '../../app_container.dart';
import '../../widget/counter_badge.dart';
import '../../widget/main_app_bar.dart';
import '../../pages/challenge_sub_page.dart';
import '../../pages/decrypt_sub_page.dart';
import '../../pages/groups_sub_page.dart';
import '../../pages/signing_sub_page.dart';
import 'offstage_navigator.dart';

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
  late List<NavigationTabModel> _tabs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabs();
  }

  @override
  Widget build(BuildContext context) {
    const double borderWidth = 1;
    const double borderOpacity = 0.2;
    const double shadowOpacity = 0.12;
    const double shadowRadius = 5;
    const Color borderColor = Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (constraints.maxWidth > minTabletLayoutWidth) ...[
              FluidGradient(),
            ],
            Container(
              padding: EdgeInsets.all(
                  constraints.maxWidth > minTabletLayoutWidth
                      ? LARGE_PADDING
                      : 0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(
                      constraints.maxWidth > minTabletLayoutWidth
                          ? LARGE_PADDING
                          : 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(LARGE_BORDER_RADIUS),
                    border: Border.all(
                        color: borderColor.withValues(alpha: borderOpacity),
                        width: borderWidth),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withValues(alpha: shadowOpacity),
                        spreadRadius: shadowRadius,
                        blurRadius: shadowRadius * 3,
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(maxWidth: minLaptopLayoutWidth),
                  child: Scaffold(
                    appBar: buildAppBar(context,
                        LayoutGetter.getCurLayout(constraints.maxWidth)),
                    body: _buildResponsiveLayout(
                        _buildIndexedStack(), constraints.maxWidth),
                    floatingActionButton: null,
                    // FabConfigurator(index: _index, buildContext: context),
                    bottomNavigationBar:
                        _buildBottomNavigation(constraints.maxWidth),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _initializeTabs() {
    _tabs = <NavigationTabModel>[
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
      NavigationTabModel(
        label: 'Settings',
        child: SettingsPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nGroupReqs,
          icon: Symbols.settings,
          fillIcon: _index == 4,
        ),
      ),
    ];
  }

  Widget _buildIndexedStack() {
    return _buildPageTransitionSwitcher(IndexedStack(
      // key: ValueKey<String>("IndexedStack_$_index"), // Causes duplicate global key error
      index: _index,
      children: _tabs.map<OffstageNavigator>(
        (NavigationTabModel destination) {
          return OffstageNavigator(
            index: _tabs.indexOf(destination),
            currentTabIndex: _index,
            navigationTab: destination,
          );
        },
      ).toList(),
    ));
  }

  Widget _buildResponsiveLayout(Widget child, double width) {
    if (width > minLaptopLayoutWidth) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: minLaptopLayoutWidth),
          child: Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _onItemTapped,
                extended: true,
                destinations: _tabs.map<NavigationRailDestination>(
                  (NavigationTabModel destination) {
                    return NavigationRailDestination(
                      icon: destination.icon,
                      label: Text(destination.label),
                    );
                  },
                ).toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      );
    } else if (width > minTabletLayoutWidth) {
      // Show the navigation rail and the child widget from the tab
      return Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _onItemTapped,
            extended: true,
            destinations: _tabs.map<NavigationRailDestination>(
              (NavigationTabModel destination) {
                return NavigationRailDestination(
                  icon: destination.icon,
                  label: Text(destination.label),
                );
              },
            ).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: child,
          ),
        ],
      );
    } else {
      // Show only the child widget from the tab. This will be followed by the bottom navigation bar
      return child;
    }
  }

  void _onItemTapped(int index) {
    if (_index == index) {
      // If the user taps the current tab again, pop to the root of that tab
      var navigatorKey = _tabs[index].navigatorKey;
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _index = index;
      });
    }
  }

  Widget _buildBottomNavigation(double width) {
    if (width > minTabletLayoutWidth) {
      return const SizedBox.shrink();
    } else {
      return NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onItemTapped,
        destinations: _tabs.map<NavigationDestination>(
          (NavigationTabModel destination) {
            return NavigationDestination(
              icon: destination.icon,
              label: destination.label,
            );
          },
        ).toList(),
      );
    }
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

  Widget _buildPageTransitionSwitcher(Widget child) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: Colors.transparent,
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}
