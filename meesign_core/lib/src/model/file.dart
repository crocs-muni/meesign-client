import 'package:meesign_core/src/model/group.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path_pkg;

@immutable
class File {
  const File(this.path, this.group);
  final String path;
  final Group group;

  String get basename => path_pkg.basename(path);
}
