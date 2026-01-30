import 'package:meesign_core/src/util/uuid.dart';
import 'package:meta/meta.dart';

@immutable
class User {
  const User(this.did, this.host);
  final Uuid did;
  final String host;
}
