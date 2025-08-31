import 'package:flutter/material.dart';

import '../l10n/arb/app_localizations.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import 'about_page.dart';
import 'device_settings_page.dart';
import 'general_settings_page.dart';
import 'group_settings_page.dart';

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
            padding:
                EdgeInsets.only(left: SMALL_PADDING, bottom: MEDIUM_PADDING),
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
    final List<Map<String, dynamic>> menuItems = [
      {
        "icon": Icons.settings,
        "text": AppLocalizations.of(context).generalSettingsTitle,
        "page": GeneralSettingsPage()
      },
      {
        "icon": Icons.devices,
        "text": AppLocalizations.of(context).deviceAndServerSettingsTitle,
        "page": DeviceSettingsPage()
      },
      {
        "icon": Icons.group,
        "text": AppLocalizations.of(context).groupSettingsTitle,
        "page": GroupSettingsPage()
      },
      {
        "icon": Icons.question_mark,
        "text": AppLocalizations.of(context).aboutThisProject,
        "page": AboutPage()
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: _getBorderRadius(index, menuItems.length),
            ),
            leading: Icon(item["icon"]),
            title: Text(item["text"]),
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                MaterialPageRoute(builder: (context) => item["page"]),
              );
            },
            trailing:
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          );
        },
      ),
    );
  }

  BorderRadius _getBorderRadius(int index, int length) {
    // This is to make the ripple effect respect the border radius
    if (index == 0) {
      return BorderRadius.vertical(top: Radius.circular(10));
    } else if (index == length - 1) {
      return BorderRadius.vertical(bottom: Radius.circular(10));
    } else {
      return BorderRadius.zero;
    }
  }
}
