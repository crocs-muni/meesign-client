import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import 'device_settings_page.dart';
import 'theme_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(builder: (context, model, child) {
      return DefaultPageTemplate(
        fullHeight: false,
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
        "icon": Icons.devices,
        "text": "Device and server",
        "page": DeviceSettingsPage()
      },
      {
        "icon": Icons.lightbulb,
        "text": "Dark / Light mode",
        "page": ThemeSettingsPage()
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
}
