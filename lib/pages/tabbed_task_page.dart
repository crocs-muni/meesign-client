import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import 'task_listing.dart';

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
                  customSearchBarHint: 'Search tasks by name...',
                ),
              ));
        });
  }
}
