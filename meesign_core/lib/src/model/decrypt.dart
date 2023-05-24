import 'package:meta/meta.dart';

import 'group.dart';

@immutable
class Decrypt {
  final String name;
  final Group group;
  final List<int> data;

  const Decrypt(this.name, this.group, this.data);
}
