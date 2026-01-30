import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/util/platform.dart';
import 'package:meesign_client/util/share_decrypt.dart';
import 'package:meesign_core/meesign_core.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    required this.imageDecrypt,
    super.key,
    this.preShareAction,
    this.postShareAction,
  });
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
        PlatformGroup.isMobile
            ? AppLocalizations.of(context).share
            : AppLocalizations.of(context).download,
      ),
      icon: Icon(PlatformGroup.isMobile ? Symbols.share : Symbols.save_alt),
    );
  }
}
