import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/model/settings.dart';
import '../app_container.dart';
import '../l10n/arb/app_localizations.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import 'groups_listing_page.dart';
import '../widget/number_input.dart';

class GroupSettingsPage extends StatelessWidget {
  const GroupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppContainer container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    return DefaultPageTemplate(
      appBarTitle: AppLocalizations.of(context).groupSettingsTitle,
      showAppBar: true,
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: settingsController.settingsStream,
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
                return CircularProgressIndicator();
              }

              final settings = settingsSnapshot.data!;

              return Column(
                children: [
                  _buildAutomationSection(
                      settingsController, settings, context),
                  SizedBox(height: XLARGE_GAP * 2),
                  _buildManageGroupsTile(context)
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationSection(
      SettingsController controller, Settings settings, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).groupAutomationSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: SMALL_GAP),
        Text(AppLocalizations.of(context).groupAutomationSettingsDescription,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
              AppLocalizations.of(context).automaticallyAcceptGroupInvitations,
              style: theme.textTheme.bodyMedium),
          value: settings.autoJoinGroups,
          onChanged: (value) {
            controller.updateAutoJoinGroups(value);
          },
        ),
        ListTile(
          title: Text(
              AppLocalizations.of(context).minimumNumberOfMembersToCreateGroup,
              style: theme.textTheme.bodyMedium),
          trailing: NumberInput(
            value: settings.minGroupMembers,
            onUpdate: (newValue) {
              if (newValue < 1) return;
              controller.updateMinGroupMembers(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManageGroupsTile(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: false).push(
              MaterialPageRoute(builder: (context) => GroupsListingPage()),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            leading: Container(
              padding: EdgeInsets.only(right: SMALL_PADDING),
              child: Icon(Icons.group),
            ),
            title: Text(AppLocalizations.of(context).manageGroups),
            subtitle: Text(
              AppLocalizations.of(context).manageGroupsDescription,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
            trailing:
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ),
        ));
  }
}
