import 'package:flutter/cupertino.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../../view_model/app_view_model.dart';
import '../../widget/error_dialog.dart';
import '../pick_pdf_file.dart';
import 'select_group.dart';

// TODO: reduce repetition across request methods
// (_sign, _challenge, _group, _encrypt)
Future<void> signDocument(
    BuildContext context, BuildContext buildContext) async {
  // Retrieve the HomeState instance before the async gap
  final homeState = buildContext.read<AppViewModel>();

  final file = await PdfPicker.pickPdfFile();
  if (file == null) return;

  if (await file.length() > AppViewModel.maxDataSize) {
    if (buildContext.mounted) {
      showErrorDialog(
        context: buildContext,
        title: 'File too large',
        desc: 'Please select a smaller one.',
      );
    }
    return;
  }

  Group? group;

  if (buildContext.mounted) {
    group = await selectGroup(KeyType.signPdf, buildContext);
  }

  if (group == null) return;

  try {
    await homeState.sign(file, group);
  } catch (e) {
    if (buildContext.mounted) {
      showErrorDialog(
        context: buildContext,
        title: 'Sign request failed',
        desc: 'Please try again.',
      );
    }
    rethrow;
  }
}
