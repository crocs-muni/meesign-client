import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../enums/fab_type.dart';
import '../pages/new_task_page.dart';
import '../util/actions/group_creator.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../view_model/app_view_model.dart';

class FabConfigurator extends StatelessWidget {
  final FabType fabType;
  final BuildContext buildContext;

  final AppViewModel? viewModel;
  const FabConfigurator(
      {super.key,
      required this.fabType,
      required this.buildContext,
      this.viewModel});

  @override
  Widget build(BuildContext context) {
    switch (fabType) {
      case FabType.groupFab:
        return _buildGroupsFab(context);
      default:
        return _buildNewTaskFab(context);
    }
  }

  Widget _buildNewTaskFab(BuildContext context) {
    String key = "NewTaskFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () async {
        Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(
              builder: (context) => NewTaskPage(
                    showTaskTypeSelector: true,
                  )),
        );
      },
      label: const Text('New task'),
      icon: const Icon(Symbols.add),
    );
  }

  Widget _buildGroupsFab(BuildContext context) {
    String key = "GroupFab";
    return FloatingActionButton.extended(
      key: ValueKey(key),
      heroTag: key,
      onPressed: () => createGroup(context, buildContext),
      label: const Text('New group'),
      icon: const Icon(Symbols.add),
    );
  }
}
