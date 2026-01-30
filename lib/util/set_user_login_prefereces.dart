import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:meesign_client/app_container.dart';
import 'package:provider/provider.dart';

void updateUserSessionPreferences(
  Uint8List userDidBytes,
  String name,
  String host,
  BuildContext context,
) {
  final userIdString = String.fromCharCodes(userDidBytes);
  context.read<AppContainer>().settingsController
    // Update last hostname so it can be automatically filled in next time
    ..saveLastHostname(host)
    // Store current user ID
    ..updateCurrentUserId(userIdString)
    // Store user ID by device/host key
    ..saveUserIdentifier(name, host, userIdString)
    // Store current host and name
    ..saveHostData(name, host)
    // Store name by user ID
    ..saveNameById(name, userIdString);
}
