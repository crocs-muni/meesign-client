import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import 'package:meesign_client/services/settings_controller.dart';

class LocalAuthService {
  /// Triggers local device authentication like FaceID/Fingerprint/Pin etc...
  /// Biometrics has higher priority if available. If no biometrics are
  /// available, it fallbacks to the normal PIN.
  /// If no local auth is available, it auto succeeds.
  /// On auth exception it fails the authentication.
  /// Use this function for protected actions like approving tasks or
  /// joining groups ...
  static Future<bool> authUser(SettingsController settingsController) async {
    final auth = LocalAuthentication();
    final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();

    // If user turned of local auth, just return true to fake success
    final currentSettings = settingsController.currentSettings;
    if (!currentSettings.authenticateProtectedActions) {
      return true;
    }

    // If the device doesn't have any way to authenticate (pin/faceID/fingerprint...)
    if (!canAuthenticate) {
      return false;
    }

    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to perform this action',
      );

      return didAuthenticate;
    } on LocalAuthException catch (e) {
      if (kDebugMode) {
        print('Local auth failed!');
        print(e);
      }

      return false;
    }
  }
}
