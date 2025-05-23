import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import '../widget/tab_selector_item.dart';
import 'groups_listing_page.dart';
import 'task_listing.dart';

class TabbedTasksPage extends StatefulWidget {
  const TabbedTasksPage({super.key});

  static void switchToTab(BuildContext context, int index) {
    if (index < 0 || index > 1) return;

    // Get the state from the context
    final state = context.findAncestorStateOfType<_TabbedTasksPageState>();
    if (state != null && state._tabController.index != index) {
      state._tabController.animateTo(index);
    }
  }

  @override
  State<TabbedTasksPage> createState() => _TabbedTasksPageState();
}

class _TabbedTasksPageState extends State<TabbedTasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
              includePadding: false,
              body: Scaffold(
                appBar: AppBar(
                    toolbarHeight: 75,
                    title: _buildHorizontalTabSelector(context)),
                body: TabBarView(
                  controller: _tabController,
                  children: const [
                    TaskListing(
                      showHeading: false,
                      customSearchBarHint: 'Search tasks by name...',
                    ),
                    GroupsListingPage(),
                  ],
                ),
              ));
        });
  }

  Widget _buildHorizontalTabSelector(BuildContext context) {
    return Container(
      height: kToolbarHeight - 8.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.primary),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor:
            WidgetStateProperty.resolveWith((states) => Colors.transparent),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer,
        tabs: [
          TabSelectorItem(
              title: "Tasks",
              stream: context.watch<AppViewModel>().nAllReqs,
              tabIcon: Icon(Symbols.task_alt)),
          TabSelectorItem(
              title: "Groups",
              stream: context.watch<AppViewModel>().nGroupReqs,
              tabIcon: Icon(Symbols.group))
        ],
      ),
    );
  }
}
