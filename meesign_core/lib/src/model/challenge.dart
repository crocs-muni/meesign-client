import 'package:meesign_core/src/model/group.dart';
import 'package:meta/meta.dart';

@immutable
class Challenge {
  const Challenge(this.name, this.group, this.data);
  final String name;
  final Group group;
  final List<int> data;
}
