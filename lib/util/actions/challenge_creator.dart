import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import '../../pages/new_task_page.dart';

void createChallenge(BuildContext context, BuildContext buildContext) async {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => NewTaskPage(initialTaskType: KeyType.signChallenge),
    ),
  );
}
