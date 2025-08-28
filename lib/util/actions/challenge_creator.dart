import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import '../../pages/new_task_page.dart';

Future<bool?> createChallenge(BuildContext context, BuildContext buildContext,
    Task? templateChallenge) async {
  return await Navigator.push(
    context,
    MaterialPageRoute<bool>(
      builder: (context) => NewTaskPage(
        initialTaskType: KeyType.signChallenge,
        templateTask: templateChallenge,
        showTaskTypeSelector: true,
      ),
    ),
  );
}
