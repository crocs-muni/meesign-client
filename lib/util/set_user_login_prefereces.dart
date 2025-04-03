import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../services/settings_controller.dart';

void updateUserSessionPreferences(
  Uint8List userDidBytes,
  String name,
  String host,
  BuildContext context,
) {
  final container = context.read<AppContainer>();
  final SettingsController settingsController = container.settingsController;

  // Update last hostname so it can be automatically filled in next time
  settingsController.saveLastHostname(host);

  // Store current user ID
  settingsController.updateCurrentUserId(
    String.fromCharCodes(userDidBytes),
  );

  // Store user ID by device/host key
  settingsController.saveUserIdentifier(
    name,
    host,
    String.fromCharCodes(userDidBytes),
  );

  // Store current host and name
  settingsController.saveHostData(
    name,
    host,
  );

  // Store name by user ID
  settingsController.saveNameById(
    name,
    String.fromCharCodes(userDidBytes),
  );
}
