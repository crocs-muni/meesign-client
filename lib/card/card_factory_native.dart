import 'package:meesign_client/card/nfc_card.dart';
import 'package:meesign_client/card/pcsc_card.dart';
import 'package:meesign_client/util/platform.dart';

dynamic create() {
  if (PlatformGroup.isAndroid || PlatformGroup.isIOS) return NfcCardManager();
  if (PlatformGroup.isLinux || PlatformGroup.isWindows) {
    return PcscCardManager();
  }
  throw UnsupportedError('Platform not supported');
}
