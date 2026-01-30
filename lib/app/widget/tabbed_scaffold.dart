import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/app/model/navigation_tab_model.dart';
import 'package:meesign_client/app/widget/offstage_navigator.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/challenge_listing_page.dart';
import 'package:meesign_client/pages/decrypt_listing_page.dart';
import 'package:meesign_client/pages/groups_listing_page.dart';
import 'package:meesign_client/pages/settings_page.dart';
import 'package:meesign_client/pages/signing_listing_page.dart';
import 'package:meesign_client/services/settings_controller.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/layout_getter.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/counter_badge.dart';
import 'package:meesign_client/widget/fluid_gradient.dart';
import 'package:meesign_client/widget/main_app_bar.dart';
import 'package:provider/provider.dart';

class TabbedScaffold extends StatelessWidget {
  const TabbedScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppContainer>().session!;

    return MultiProvider(
      providers: [
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
      ],
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
  List<NavigationTabModel> _tabs = [];

  late final AppContainer container = context.read<AppContainer>();
  late final SettingsController settingsController =
      container.settingsController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabs();
  }

  @override
  Widget build(BuildContext context) {
    const borderOpacity = 0.2;
    const shadowOpacity = 0.12;
    const double shadowRadius = 5;
    const borderColor = Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (constraints.maxWidth > minTabletLayoutWidth) ...[
              const FluidGradient(),
            ],
            Container(
              padding: EdgeInsets.all(
                constraints.maxWidth > minTabletLayoutWidth ? LARGE_PADDING : 0,
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(
                    constraints.maxWidth > minTabletLayoutWidth
                        ? LARGE_PADDING
                        : 0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      constraints.maxWidth > minTabletLayoutWidth
                          ? LARGE_BORDER_RADIUS
                          : 0,
                    ),
                    border: Border.all(
                      color: borderColor.withValues(alpha: borderOpacity),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withValues(alpha: shadowOpacity),
                        spreadRadius: shadowRadius,
                        blurRadius: shadowRadius * 3,
                      ),
                    ],
                  ),
                  constraints:
                      const BoxConstraints(maxWidth: minLaptopLayoutWidth),
                  child: Scaffold(
                    appBar: buildAppBar(
                      context,
                      LayoutGetter.getCurLayout(constraints.maxWidth),
                    ),
                    body: _buildResponsiveLayout(
                      _buildIndexedStack(),
                      constraints.maxWidth,
                    ),
                    bottomNavigationBar:
                        _buildBottomNavigation(constraints.maxWidth),
                  ),
                ),
              ),
            ),
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

    _tabs = _generateTabs();
  }

  List<NavigationTabModel> _generateTabs() {
    return <NavigationTabModel>[
      NavigationTabModel(
        label: AppLocalizations.of(context).signings,
        child: const SigningListingPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nSignReqs,
          icon: Symbols.draw,
          fillIcon: context.read<TabsViewModel>().index == 0,
        ),
      ),
      NavigationTabModel(
        label: AppLocalizations.of(context).challenges,
        child: const ChallengeListingPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nChallengeReqs,
          icon: Symbols.quiz,
          fillIcon: context.read<TabsViewModel>().index == 1,
        ),
      ),
      NavigationTabModel(
        label: AppLocalizations.of(context).decryptions,
        child: const DecryptListingPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nDecryptReqs,
          icon: Symbols.key,
          fillIcon: context.read<TabsViewModel>().index == 2,
        ),
      ),
      NavigationTabModel(
        label: AppLocalizations.of(context).groups,
        child: const GroupsListingPage(),
        icon: _buildCounterIcon(
          stream: context.watch<AppViewModel>().nGroupReqs,
          icon: Symbols.group,
          fillIcon: context.read<TabsViewModel>().index == 3,
        ),
      ),
      NavigationTabModel(
        label: AppLocalizations.of(context).settings,
        child: const SettingsPage(),
        icon: const Icon(Symbols.settings),
      ),
    ];
  }

  Widget _buildIndexedStack() {
    return _buildPageTransitionSwitcher(
      IndexedStack(
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
      ),
    );
  }

  Widget _buildReactiveTabLabel(NavigationTabModel destination) {
    // Since we initialize _tabs only once to prevent losing state of the OffstageNavigators,
    // we need to rebuild the labels reactively to reflect the current language.
    return StreamBuilder(
      stream: settingsController.settingsStream,
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
          return Text(destination.label);
        }

        final tabs = _generateTabs();
        return Text(tabs[_tabs.indexOf(destination)].label);
      },
    );
  }

  Widget _buildReactiveNavigationDestination(NavigationTabModel destination) {
    return StreamBuilder(
      stream: settingsController.settingsStream,
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
          return NavigationDestination(
            icon: destination.icon,
            label: destination.label,
          );
        }

        final tabs = _generateTabs();
        return NavigationDestination(
          icon: destination.icon,
          label: tabs[_tabs.indexOf(destination)].label,
        );
      },
    );
  }

  Widget _buildResponsiveLayout(Widget child, double width) {
    if (width > minLaptopLayoutWidth) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: minLaptopLayoutWidth),
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
                      label: _buildReactiveTabLabel(destination),
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
                  label: _buildReactiveTabLabel(destination),
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
      final navigatorKey = _tabs[index].navigatorKey;
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
        destinations: _tabs
            .map(
              _buildReactiveNavigationDestination,
            )
            .toList(),
      );
    }
  }

  Widget _buildCounterIcon({
    required Stream<int> stream,
    required IconData icon,
    bool fillIcon = false,
  }) {
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
