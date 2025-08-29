import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import '../../pages/new_task_page.dart';

Future<bool?> encryptData(
    {required BuildContext context,
    required BuildContext buildContext,
    Task? templateDecryptTask}) async {
  return await Navigator.push(
    context,
    MaterialPageRoute<bool>(
      builder: (context) => NewTaskPage(
        initialTaskType: KeyType.decrypt,
        templateTask: templateDecryptTask,
        showTaskTypeSelector: true,
      ),
    ),
  );
}
