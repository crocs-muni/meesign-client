import 'package:meta/meta.dart';

import 'group.dart';

@immutable
class Challenge {
  final String name;
  final Group group;
  final List<int> data;

  const Challenge(this.name, this.group, this.data);
}
