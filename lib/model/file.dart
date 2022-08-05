import 'package:path/path.dart' as path_pkg;

import 'group.dart';

class File {
  String path;
  Group group;

  File(this.path, this.group);

  String get basename => path_pkg.basename(path);
}
