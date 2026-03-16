import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:meesign_client/app/model/settings.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/services/local_auth_service.dart';
import 'package:meesign_client/services/settings_controller.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:provider/provider.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final container = context.read<AppContainer>();
    final settingsController = container.settingsController;

    return DefaultPageTemplate(
      appBarTitle: AppLocalizations.of(context).generalSettingsTitle,
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
                  _buildLanguageSettingsSection(
                    settingsController,
                    settings,
                    context,
                  ),
                  const SizedBox(height: XLARGE_GAP * 2),
                  _buildThemeSettingsSection(
                    settingsController,
                    settings,
                    context,
                  ),
                  const SizedBox(height: XLARGE_GAP * 2),
                  _buildArchivedSettingsSection(
                    settingsController,
                    settings,
                    context,
                  ),
                  const SizedBox(height: XLARGE_GAP * 2),
                  _buildCloseAppConfirmationSettingsSection(
                    settingsController,
                    settings,
                    context,
                  ),
                  const SizedBox(height: XLARGE_GAP * 2),
                  _buildAuthenticateProtectedActionsSettingsSection(
                    settingsController,
                    settings,
                    context,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).themeSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).themeSettingsDescription,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).useSystemTheme,
            style: theme.textTheme.bodyMedium,
          ),
          value: settings.themeMode == ThemeMode.system,
          onChanged: (value) {
            controller.updateThemeMode(
              value ? ThemeMode.system : controller.getSystemBrightness(),
            );
          },
        ),
        if (settings.themeMode != ThemeMode.system) ...[
          SwitchListTile(
            title: Text(
              AppLocalizations.of(context).darkMode,
              style: theme.textTheme.bodyMedium,
            ),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              controller
                  .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildArchivedSettingsSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).archivationSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).archivationSettingsDescription,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).showArchivedItems,
            style: theme.textTheme.bodyMedium,
          ),
          value: settings.showArchivedItems,
          onChanged: (value) {
            controller.updateShowArchivedItems(showArchivedItems: value);
          },
        ),
      ],
    );
  }

  Widget _buildCloseAppConfirmationSettingsSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).confirmCloseSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).confirmCloseSettingsDesc,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).confirmCloseSettings,
            style: theme.textTheme.bodyMedium,
          ),
          value: !settings.closeWithoutConfirmation,
          onChanged: (value) {
            controller.updateCloseWithoutConfirmation(
              closeWithoutConfirmation: !value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuthenticateProtectedActionsSettingsSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)
              .authenticateProtectedActionsSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).authenticateProtectedActionsSettingsDesc,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).authenticateProtectedActionsSettings,
            style: theme.textTheme.bodyMedium,
          ),
          value: settings.authenticateProtectedActions,
          onChanged: (value) async {
            if (!value) {
              final authenticated = await LocalAuthService.authUser(controller);
              if (!authenticated) return;
            }
            controller.updateAuthenticateProtectedActions(
              authenticateProtectedActions: value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSettingsSection(
    SettingsController controller,
    Settings settings,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).languageSettingsTitle,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: SMALL_GAP),
        Text(
          AppLocalizations.of(context).languageSettingsDescription,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
        const SizedBox(height: SMALL_GAP),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              value: settings.currentLanguage,
              isExpanded: true,
              style: theme.textTheme.bodyMedium,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  controller.updateCurrentLanguage(newLanguage);
                }
              },
              items: controller
                  .getAvailableLanguages()
                  .map<DropdownMenuItem<String>>((String languageCode) {
                return DropdownMenuItem<String>(
                  value: languageCode,
                  child: Text(
                    controller.getLanguageDisplayName(languageCode),
                  ),
                );
              }).toList(),
              buttonStyleData: ButtonStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SMALL_PADDING),
                ),
              ),
              iconStyleData: IconStyleData(
                icon: Padding(
                  padding: const EdgeInsetsGeometry.only(right: SMALL_PADDING),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
                ),
                offset: const Offset(0, -4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
