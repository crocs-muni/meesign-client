import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';

import '../util/platform.dart';
import '../util/share_decrypt.dart';

class ShareButton extends StatelessWidget {
  const ShareButton(
      {super.key,
      required this.imageDecrypt,
      this.preShareAction,
      this.postShareAction});
  final Decrypt? imageDecrypt;
  final Function? preShareAction;
  final Function? postShareAction;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        if (preShareAction != null) {
          await preShareAction!();
        }
        await ShareController.shareDecrypt(imageDecrypt!);

        if (postShareAction != null) {
          await postShareAction!();
        }
      },
      label: Text(
        PlatformGroup.isMobile ? 'Share' : 'Download',
      ),
      icon: Icon(PlatformGroup.isMobile ? Symbols.share : Symbols.save_alt),
    );
  }
}
