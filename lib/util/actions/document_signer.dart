import 'package:flutter/material.dart';
import 'package:meesign_client/pages/new_task_page.dart';
import 'package:meesign_core/meesign_core.dart';

Future<bool?> signDocument({
  required BuildContext context,
  required BuildContext buildContext,
  Task? templateSignTask,
}) async {
  return Navigator.push(
    context,
    MaterialPageRoute<bool>(
      builder: (context) => NewTaskPage(
        initialTaskType: KeyType.signPdf,
        templateTask: templateSignTask,
        showTaskTypeSelector: true,
      ),
    ),
  );
}
