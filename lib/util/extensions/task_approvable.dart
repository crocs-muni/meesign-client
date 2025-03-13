import 'package:meesign_core/meesign_core.dart';

extension TaskDetails on Task {
  bool get approvable =>
      !approved && (state == TaskState.created || state == TaskState.running);
}
