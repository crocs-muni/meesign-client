import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:meesign_client/util/platform.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';

class ShareController {
  static Future<void> shareDecrypt(Decrypt decrypt) async {
    final file = XFile.fromData(
      decrypt.data as Uint8List,
      name: decrypt.name,
      mimeType: decrypt.dataType.value,
    );

    if (PlatformGroup.isDesktop) {
      final ext = extensionFromMime(decrypt.dataType.value);
      final loc = await getSaveLocation(
        suggestedName: '${decrypt.name}.$ext',
      );
      if (loc != null) {
        file.saveTo(loc.path);
      }
    }
    if (PlatformGroup.isMobile) {
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: decrypt.name,
        ),
      );
    }
  }
}
