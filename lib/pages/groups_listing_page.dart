import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../enums/fab_type.dart';
import '../enums/task_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/group_creator.dart';
import '../view_model/app_view_model.dart';
import '../widget/controlled_lottie_animation.dart';
import '../widget/fab_configurator.dart';
import '../widget/task_tiles/group_task_tile.dart';
import '../widget/task_list_view.dart';

import '../view_model/tabs_view_model.dart';

class GroupsListingPage extends StatefulWidget {
  const GroupsListingPage({super.key});

  @override
  State<GroupsListingPage> createState() => _GroupsListingPageState();
}

class _GroupsListingPageState extends State<GroupsListingPage> {
  late TabsViewModel _tabsViewModel;

  @override
  void initState() {
    super.initState();
    _tabsViewModel = Provider.of<TabsViewModel>(context, listen: false);
    _tabsViewModel.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabsViewModel.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabsViewModel.index == 2) {
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
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder<TaskStream>(
        stream: model.combinedTaskStream,
        builder: (context, snapshot) {
          return DefaultPageTemplate(
              floatingActionButton: _buildFab(context, model),
              body: TaskListView<Group>(
                key: ValueKey('group_task_list'),
                tasks: model.groupTasks,
                emptyView: _buildEmptyGroups(context),
                showArchived: model.showArchived,
                showAllTypes: true,
                taskBuilder: (context, task) {
                  final group = task.info;
                  return GroupTaskTile(task: task, group: group);
                },
              ));
        });
  }

  Widget _buildFab(BuildContext context, AppViewModel model) {
    if (model.groupTasks.where((task) => task.archived).isNotEmpty) {
      if (context.read<AppViewModel>().showArchived) {
        return FabConfigurator(
            fabType: FabType.groupFab, buildContext: context);
      }
    }

    // Don't show Fab if the list is empty - placeholder with CTA is shown instead
    if (model.groupTasks.where((task) => !task.archived).isEmpty) {
      return SizedBox();
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
              padding: EdgeInsets.only(bottom: MEDIUM_PADDING),
              child: ControlledLottieAnimation(
                startAtTabIndex: 2,
                assetName: Theme.of(context).brightness == Brightness.light
                    ? 'assets/lottie/groups_light_mode.json'
                    : 'assets/lottie/groups_dark_mode.json',
                stopAtPercentage: 0.5,
                width: 400,
                fit: BoxFit.fitWidth,
              ),
            ),
            const Text(
              'No groups yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SMALL_GAP),
            const Text(
              'Create a group to get started.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LARGE_GAP),
            ElevatedButton(
              onPressed: () {
                createGroup(context, context);
              },
              child: const Text('Create group'),
            )
          ],
        ),
      ),
    );
  }
}
