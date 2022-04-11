import 'package:path/path.dart' as path_pkg;

import 'group.dart';

class SignedFile {
  String path;
  Group group;
  bool isFinished = false;

  SignedFile(this.path, this.group);

  String get basename => path_pkg.basename(path);
}
