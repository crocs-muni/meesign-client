import 'package:flutter/material.dart';
import 'package:meesign_client/enums/fab_type.dart';
import 'package:meesign_client/enums/task_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/group_page.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/group_creator.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/controlled_lottie_animation.dart';
import 'package:meesign_client/widget/fab_configurator.dart';
import 'package:meesign_client/widget/task_list_view.dart';
import 'package:meesign_client/widget/task_tiles/group_task_tile.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:provider/provider.dart';

class GroupsListingPage extends StatefulWidget {
  const GroupsListingPage({super.key});

  @override
  State<GroupsListingPage> createState() => _GroupsListingPageState();
}

class _GroupsListingPageState extends State<GroupsListingPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabsViewModel _tabsViewModel;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabsViewModel = Provider.of<TabsViewModel>(context, listen: false);
    _tabsViewModel.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabsViewModel.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabsViewModel.index == 3) {
      if (!_tabsViewModel.newGroupPageActive) {
        if (_tabsViewModel.postNavigationAction == 'createChallengeGroup') {
          createGroup(context, context, groupType: TaskType.challenge);
        }

        if (_tabsViewModel.postNavigationAction == 'createSignGroup') {
          createGroup(context, context, groupType: TaskType.sign);
        }

        if (_tabsViewModel.postNavigationAction == 'createEncryptGroup') {
          createGroup(context, context, groupType: TaskType.encrypt);
        }

        if (_tabsViewModel.postNavigationAction == 'createDecryptGroup') {
          createGroup(context, context, groupType: TaskType.decrypt);
        }

        if (_tabsViewModel.postNavigationAction == 'createGroup') {
          createGroup(context, context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder<TaskStream>(
      stream: model.combinedTaskStream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MEDIUM_PADDING,
                vertical: SMALL_PADDING,
              ),
              child: _buildTabBar(context),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyGroupsTab(context, model),
                  _buildOtherGroupsTab(context, model),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: kToolbarHeight - 8.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor:
            WidgetStateProperty.resolveWith((states) => Colors.transparent),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer,
        tabs: [
          Tab(text: AppLocalizations.of(context).myGroups),
          Tab(text: AppLocalizations.of(context).otherGroups),
        ],
      ),
    );
  }

  Widget _buildMyGroupsTab(BuildContext context, AppViewModel model) {
    return DefaultPageTemplate(
      floatingActionButton: _buildFab(context, model),
      body: TaskListView<Group>(
        key: const ValueKey('group_task_list'),
        tasks: model.groupTasks,
        customSearchBarHint: 'Search groups by name...',
        emptyView: _buildEmptyGroups(context),
        showArchived: model.showArchived,
        taskBuilder: (context, task) {
          final group = task.info;
          return GroupTaskTile(task: task, group: group);
        },
      ),
    );
  }

  Widget _buildOtherGroupsTab(BuildContext context, AppViewModel model) {
    return StreamBuilder<List<Group>>(
      stream: model.externalGroupsStream,
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];

        if (groups.isEmpty) {
          return _buildEmptyOtherGroups(context, model);
        }

        return _OtherGroupsList(
          groups: groups,
          onRefresh: () => model.fetchExternalGroups(),
        );
      },
    );
  }

  Widget _buildEmptyOtherGroups(BuildContext context, AppViewModel model) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: MEDIUM_GAP),
            Text(
              AppLocalizations.of(context).noOtherGroupsAvailable,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: MEDIUM_GAP),
            IconButton(
              onPressed: () => model.fetchExternalGroups(),
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context).refreshGroups,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    if (model.groupTasks.where((task) => task.archived).isNotEmpty) {
      if (context.read<AppViewModel>().showArchived) {
        return FabConfigurator(
          fabType: FabType.groupFab,
          buildContext: context,
        );
      }
    }

    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.groupTasks.where((task) => !task.archived).isEmpty) {
      return const SizedBox();
    }

    return FabConfigurator(fabType: FabType.groupFab, buildContext: context);
  }

  Widget _buildEmptyGroups(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: MEDIUM_PADDING),
              child: ControlledLottieAnimation(
                startAtTabIndex: 3,
                assetName: Theme.of(context).brightness == Brightness.light
                    ? 'assets/lottie/groups_light_mode.json'
                    : 'assets/lottie/groups_dark_mode.json',
                stopAtPercentage: 0.5,
                width: 400,
                fit: BoxFit.fitWidth,
              ),
            ),
            Text(
              AppLocalizations.of(context).noGroupsYet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SMALL_GAP),
            Text(
              AppLocalizations.of(context).createGroupToStart,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LARGE_GAP),
            ElevatedButton(
              onPressed: () {
                createGroup(context, context);
              },
              child: Text(AppLocalizations.of(context).createGroup),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherGroupsList extends StatefulWidget {
  const _OtherGroupsList({
    required this.groups,
    required this.onRefresh,
  });

  final List<Group> groups;
  final Future<void> Function() onRefresh;

  @override
  State<_OtherGroupsList> createState() => _OtherGroupsListState();
}

class _OtherGroupsListState extends State<_OtherGroupsList> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Group> get _filteredGroups {
    if (_searchQuery.isEmpty) return widget.groups;
    final query = _searchQuery.toLowerCase();
    return widget.groups
        .where((g) => g.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: SMALL_GAP),
              _buildSearchBar(context),
              const SizedBox(height: SMALL_GAP),
              Row(
                children: [
                  _buildReloadButton(),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
        Expanded(
          child: _isReloading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? AppLocalizations.of(context)
                                .noTasksFoundForQuery(_searchQuery)
                            : AppLocalizations.of(context)
                                .noOtherGroupsAvailable,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: widget.onRefresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: MEDIUM_PADDING,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildGroupTile(context, filtered[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      maxLength: 100,
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Search groups by name...',
        prefixIcon: const Icon(Icons.search),
        fillColor: Theme.of(context).colorScheme.onInverseSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  Widget _buildReloadButton() {
    return TextButton.icon(
      onPressed: _isReloading
          ? null
          : () async {
              setState(() => _isReloading = true);
              try {
                await widget.onRefresh();
                await Future<void>.delayed(
                  const Duration(milliseconds: 500),
                );
              } finally {
                if (mounted) setState(() => _isReloading = false);
              }
            },
      icon: _isReloading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(AppLocalizations.of(context).refreshGroups),
    );
  }

  Widget _buildGroupTile(BuildContext context, Group group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SMALL_PADDING),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            child: Text(group.name.initials),
          ),
          title: Text(
            group.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${group.members.length} members | '
            '${group.threshold}/${group.shares} threshold | '
            '${group.protocol.name.toUpperCase()}',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => GroupPage(group: group),
              ),
            );
          },
        ),
      ),
    );
  }
}
