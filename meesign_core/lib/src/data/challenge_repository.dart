import 'dart:typed_data';

import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../model/challenge.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/uuid.dart';
import 'group_repository.dart';
import 'task_repository.dart';

class ChallengeRepository extends TaskRepository<Challenge> {
  final GroupRepository _groupRepository;

  ChallengeRepository(
    TaskSource taskSource,
    this._groupRepository,
  ) : super(taskSource);

  @override
  Future<Task<Challenge>> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.SignRequest.fromBuffer(rpcTask.request);

    final group = await _groupRepository.findGroupById(did, req.groupId);
    if (group == null) throw StateException();

    return Task<Challenge>(
      id: Uuid(rpcTask.id),
      nRounds: group.protocol.signRounds,
      context: Uint8List(0),
      info: Challenge(req.name, group, req.data),
    );
  }

  @override
  Task<Challenge> initTask(Task<Challenge> task) => task.copyWith(
        context: ProtocolWrapper.sign(
          task.info.group.protocol.toNative(),
          task.info.group.context,
        ),
      );

  @override
  Future<void> finishTask(
      Uuid did, Task<Challenge> task, rpc.Task rpcTask) async {
    if (task.context.isNotEmpty) ProtocolWrapper.finish(task.context);
  }

  @override
  bool isSyncable(rpc.Task rpcTask) =>
      rpcTask.type == rpc.TaskType.SIGN_CHALLENGE;
}
