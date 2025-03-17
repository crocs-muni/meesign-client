import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../view_model/app_view_model.dart';
import 'ui_mode_select_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
        body: Consumer<AppViewModel>(builder: (context, model, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Work",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildMenuItems(context),
          ],
        ),
      );
    }));
  }

  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.settings, "text": "UI mode"},
    ];

    return Card(
      color: Colors.black26, // Slight background contrast
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: menuItems.map((item) {
          return ListTile(
            leading: Icon(item["icon"], color: Colors.white),
            title: Text(item["text"], style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                MaterialPageRoute(builder: (context) => UiModeSelectPage()),
              );
            },
            trailing:
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          );
        }).toList(),
      ),
    );
  }
}
