import 'package:flutter/material.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/about_page.dart';
import 'package:meesign_client/pages/device_settings_page.dart';
import 'package:meesign_client/pages/general_settings_page.dart';
import 'package:meesign_client/pages/group_settings_page.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      wrapInScroll: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: SMALL_PADDING,
              bottom: MEDIUM_PADDING,
            ),
            child: Text(
              AppLocalizations.of(context).applicationSettingsTitle,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.settings,
        'text': AppLocalizations.of(context).generalSettingsTitle,
        'page': const GeneralSettingsPage(),
      },
      {
        'icon': Icons.devices,
        'text': AppLocalizations.of(context).deviceAndServerSettingsTitle,
        'page': const DeviceSettingsPage(),
      },
      {
        'icon': Icons.group,
        'text': AppLocalizations.of(context).groupSettingsTitle,
        'page': const GroupSettingsPage(),
      },
      {
        'icon': Icons.question_mark,
        'text': AppLocalizations.of(context).aboutThisProject,
        'page': const AboutPage(),
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: _getBorderRadius(index, menuItems.length),
            ),
            leading: Icon(item['icon'] as IconData),
            title: Text(item['text'] as String),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => item['page'] as Widget,
                ),
              );
            },
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white70,
            ),
          );
        },
      ),
    );
  }

  BorderRadius _getBorderRadius(int index, int length) {
    // This is to make the ripple effect respect the border radius
    if (index == 0) {
      return const BorderRadius.vertical(top: Radius.circular(10));
    } else if (index == length - 1) {
      return const BorderRadius.vertical(bottom: Radius.circular(10));
    } else {
      return BorderRadius.zero;
    }
  }
}
