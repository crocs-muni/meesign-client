import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../pages/settings_page.dart';
import '../../pages/tabbed_task_page.dart';
import '../../ui_constants.dart';
import '../../util/layout_getter.dart';
import '../../view_model/app_view_model.dart';
import '../../view_model/tabs_view_model.dart';
import '../../widget/fluid_gradient.dart';
import '../model/navigation_tab_model.dart';
import '../../app_container.dart';
import '../../widget/main_app_bar.dart';
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

  static void openSettingsInContext(BuildContext context) {
    final tabsViewModel = Provider.of<TabsViewModel>(context, listen: false);
    final currentIndex = tabsViewModel.index;
    final tabsState = context.findAncestorStateOfType<_HomePageViewState>();

    if (tabsState != null && tabsState._tabs.isNotEmpty) {
      final navigatorKey = tabsState._tabs[currentIndex].navigatorKey;
      bool isSettingsOpen = false;
      navigatorKey.currentState?.popUntil((route) {
        if (route.settings.name == 'settings' ||
            (route is MaterialPageRoute &&
                route.builder(context) is SettingsPage)) {
          isSettingsOpen = true;
        }
        return true;
      });

      // Only open settings if not already open
      if (!isSettingsOpen) {
        navigatorKey.currentState?.push(
          MaterialPageRoute<void>(
            builder: (context) => SettingsPage(),
            fullscreenDialog: false,
            maintainState: true,
            settings: const RouteSettings(name: 'settings'),
          ),
        );
      }
    }
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
                    body: _buildIndexedStack(),
                    floatingActionButton: null,
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
        label: 'Tabs',
        child: TabbedTasksPage(),
        icon: Icon(Symbols.task_alt),
      ),
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
