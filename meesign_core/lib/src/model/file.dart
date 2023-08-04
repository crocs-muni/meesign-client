import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_pkg;

import 'group.dart';

@immutable
class File {
  final String name;
  final String path;
  final Group group;

  const File(this.name, this.path, this.group);
}
