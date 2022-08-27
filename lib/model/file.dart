import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_pkg;

import 'group.dart';

@immutable
class File {
  final String path;
  final Group group;

  const File(this.path, this.group);

  String get basename => path_pkg.basename(path);
}
