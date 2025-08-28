import 'package:flutter/widgets.dart';
import 'package:meesign_core/meesign_core.dart';

import '../l10n/arb/app_localizations.dart';

class StatusMessage {
  static String? getStatusMessage(Task task, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (task.state) {
      TaskState.created => task.approved
          ? l10n.waitingForConfirmationByOthers
          : l10n.waitingForConfirmation,
      TaskState.running => l10n.workingOnTask,
      TaskState.needsCard => l10n.needsCardToContinue,
      _ => null,
    };
  }
}
