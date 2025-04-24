import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../pages/settings_page.dart';
import '../../pages/task_listing.dart';
import '../../ui_constants.dart';
import '../../util/layout_getter.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/tabs_view_model.dart';
import '../../widget/fluid_gradient.dart';
import '../model/navigation_tab_model.dart';
import '../../app_container.dart';
import '../../widget/counter_badge.dart';
import '../../widget/main_app_bar.dart';
import '../../pages/groups_listing_page.dart';
import 'offstage_navigator.dart';

class TabbedScaffold extends StatelessWidget {
  const TabbedScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppContainer>().session!;

    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => TabsViewModel()),
      ChangeNotifierProvider(
        create: (context) => AppViewModel(
          session.user,
          session.deviceRepository,
          session.groupRepository,
          session.fileRepository,
          session.challengeRepository,
          session.decryptRepository,
          context.read<AppContainer>().settingsController,
        ),
      ),
    ], child: const HomePageView());
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  List<NavigationTabModel> _tabs = [];

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
    // Since the tabs are initialized in didChangeDependencies
    // we need to check if they are already initialized.
    // We cant initialize them in initState because we
    // need the context to get the AppViewModel
    if (_tabs.isNotEmpty) {
      return;
    }

    _tabs = <NavigationTabModel>[
      NavigationTabModel(
        label: 'All Tasks',
        child: TaskListing(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nAllReqs,
          icon: Symbols.task,
          fillIcon: context.read<TabsViewModel>().index == 0,
        ),
      ),
      NavigationTabModel(
        label: 'Groups',
        child: GroupsListingPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nGroupReqs,
          icon: Symbols.group,
          fillIcon: context.read<TabsViewModel>().index == 1,
        ),
      ),
      NavigationTabModel(
          label: 'Settings',
          child: SettingsPage(),
          icon: Icon(Symbols.settings))
    ];
  }

  Widget _buildIndexedStack() {
    return _buildPageTransitionSwitcher(IndexedStack(
      // key: ValueKey<String>("IndexedStack_$_index"), // Causes duplicate global key error
      index: context.watch<TabsViewModel>().index,
      children: _tabs.map<OffstageNavigator>(
        (NavigationTabModel destination) {
          return OffstageNavigator(
            index: _tabs.indexOf(destination),
            currentTabIndex: context.watch<TabsViewModel>().index,
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
                selectedIndex: context.read<TabsViewModel>().index,
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
            selectedIndex: context.read<TabsViewModel>().index,
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
    if (context.read<TabsViewModel>().index == index) {
      // If the user taps the current tab again, pop to the root of that tab
      var navigatorKey = _tabs[index].navigatorKey;
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        context.read<TabsViewModel>().setIndex(index);
      });
    }
  }

  Widget _buildBottomNavigation(double width) {
    if (width > minTabletLayoutWidth) {
      return const SizedBox.shrink();
    } else {
      return NavigationBar(
        selectedIndex: context.watch<TabsViewModel>().index,
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
