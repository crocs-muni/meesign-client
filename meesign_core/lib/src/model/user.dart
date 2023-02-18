import 'package:meta/meta.dart';

import '../util/uuid.dart';

@immutable
class User {
  final Uuid did;
  final String host;

  User(this.did, this.host);
}
