import 'package:meta/meta.dart';

import '../util/mime_type.dart';
import 'group.dart';

@immutable
class Decrypt {
  final String name;
  final Group group;
  final MimeType dataType;
  final List<int> data;

  const Decrypt(this.name, this.group, this.dataType, this.data);
}
