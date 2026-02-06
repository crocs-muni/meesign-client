class AppDirGetter {
  static Future<String> getAppDir() async {
    // On web, storage is handled by IndexedDB/OPFS.
    // Return a placeholder path; stores ignore it.
    return '';
  }
}
