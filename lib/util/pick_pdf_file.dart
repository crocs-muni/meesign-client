import 'package:file_selector/file_selector.dart';

class PdfPicker {
  static Future<XFile?> pickPdfFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'PDF Documents', extensions: ['pdf']),
      ],
    );

    return file;
  }
}
