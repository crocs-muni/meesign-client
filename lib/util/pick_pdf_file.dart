import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

class PdfPicker {
  static Future<XFile?> pickPdfFile() async {
    XFile? file;

    if (Platform.isAndroid) {
      // TODO: migrate to file_selector completely
      // once it allows us to retrieve the display name of the file
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );
      final path = res?.files.firstOrNull?.path;
      if (path != null) file = XFile(path);
    } else {
      file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF Documents', extensions: ['pdf']),
        ],
      );
    }

    return file;
  }
}
