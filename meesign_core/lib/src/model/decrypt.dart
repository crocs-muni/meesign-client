import 'package:meesign_core/src/model/group.dart';
import 'package:meesign_core/src/util/mime_type.dart';
import 'package:meta/meta.dart';

@immutable
class Decrypt {
  const Decrypt(this.name, this.group, this.dataType, this.data);
  final String name;
  final Group group;
  final MimeType dataType;
  final List<int> data;
}
