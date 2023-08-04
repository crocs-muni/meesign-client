import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_pkg;

import 'group.dart';

@immutable
class File {
  final String id;
  final String name;
  final Group group;

  const File(this.id, this.name, this.group);
}
