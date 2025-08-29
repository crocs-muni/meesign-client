import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../../pages/new_task_page.dart';

Future<bool?> signDocument(
    {required BuildContext context,
    required BuildContext buildContext,
    Task? templateSignTask}) async {
  return await Navigator.push(
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
