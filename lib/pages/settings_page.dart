import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import 'about_page.dart';
import 'device_settings_page.dart';
import 'general_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return DefaultPageTemplate(
        wrapInScroll: true,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("What do you want to do?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildMenuItems(context),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "icon": Icons.settings,
        "text": "General settings",
        "page": GeneralSettingsPage()
      },
      {
        "icon": Icons.devices,
        "text": "Device and server",
        "page": DeviceSettingsPage()
      },
      {
        "icon": Icons.question_mark,
        "text": "About this project",
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
