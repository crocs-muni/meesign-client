import 'package:flutter/material.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/task_listing.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:provider/provider.dart';

class TabbedTasksPage extends StatelessWidget {
  const TabbedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AppViewModel>(context, listen: false);

    return StreamBuilder(
      stream: model.combinedTaskStream,
      builder: (context, snapshot) {
        return DefaultPageTemplate(
          includePadding: false,
          body: Scaffold(
            body: TaskListing(
              showHeading: false,
              customSearchBarHint:
                  AppLocalizations.of(context).searchTasksByName,
            ),
          ),
        );
      },
    );
  }
}
