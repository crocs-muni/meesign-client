import 'package:flutter/material.dart';
import 'package:meesign_client/app/model/settings.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/services/settings_controller.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/view_model/tabs_view_model.dart';
import 'package:meesign_client/widget/number_input.dart';
import 'package:provider/provider.dart';

class GroupSettingsPage extends StatelessWidget {
  const GroupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final container = context.read<AppContainer>();
    final settingsController = container.settingsController;

    return DefaultPageTemplate(
      appBarTitle: AppLocalizations.of(context).groupSettingsTitle,
      showAppBar: true,
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: settingsController.settingsStream,
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final settings = settingsSnapshot.data!;

              return Column(
                children: [
                  _buildAutomationSection(
                    settingsController,
                    settings,
                    context,
                  ),
                  const SizedBox(height: XLARGE_GAP * 2),
                  _buildManageGroupsTile(context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
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
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).groupAutomationSettingsDescription,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).automaticallyAcceptGroupInvitations,
            style: theme.textTheme.bodyMedium,
          ),
          value: settings.autoJoinGroups,
          onChanged: (value) {
            controller.updateAutoJoinGroups(autoJoin: value);
          },
        ),
        SwitchListTile(
          title: Text(
            'Auto-reject group invitations',
            style: theme.textTheme.bodyMedium,
          ),
          value: settings.autoRejectGroups,
          onChanged: (value) {
            controller.updateAutoRejectGroups(autoReject: value);
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).minimumNumberOfMembersToCreateGroup,
            style: theme.textTheme.bodyMedium,
          ),
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
          context.read<TabsViewModel>().setIndex(3); // 3 = Groups tab
        },
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          mouseCursor: SystemMouseCursors.click,
          leading: Container(
            padding: const EdgeInsets.only(right: SMALL_PADDING),
            child: const Icon(Icons.group),
          ),
          title: Text(AppLocalizations.of(context).manageGroups),
          subtitle: Text(
            AppLocalizations.of(context).manageGroupsDescription,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
