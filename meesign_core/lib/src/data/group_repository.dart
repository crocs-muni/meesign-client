import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:rxdart/subjects.dart';

import '../model/device.dart';
import '../model/group.dart';
import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';
import 'device_repository.dart';
import 'task_repository.dart';

// TODO: hide the group context from the outside world?

class GroupRepository extends TaskRepository<GroupBase> {
  final rpc.MPCClient _rpcClient;
  final DeviceRepository _deviceRepository;

  // Group also contains device-specific context, hence one map for each device
  final DefaultMap<Uuid, Map<List<int>, Group>> _groups = DefaultMap(
    HashMap(),
    () => HashMap(
      equals: const ListEquality().equals,
      hashCode: const ListEquality().hash,
    ),
  );

  final DefaultMap<Uuid, BehaviorSubject<List<Group>>> _groupsSubjects =
      DefaultMap(HashMap(), () => BehaviorSubject.seeded([]));

  GroupRepository(this._rpcClient, this._deviceRepository) : super(_rpcClient);

  Future<void> group(
    String name,
    List<Device> members,
    int threshold,
  ) async {
    await _rpcClient.group(
      rpc.GroupRequest(
        deviceIds: members.map((m) => m.id.bytes),
        name: name,
        threshold: threshold,
        protocol: rpc.ProtocolType.GG18,
        keyType: rpc.KeyType.SignPDF,
      ),
    );

    // TODO: add task immediately instead of waiting for the next sync
  }

  @override
  Future<Task<GroupBase>> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.GroupRequest.fromBuffer(rpcTask.request);

    final ids = req.deviceIds.map((id) => Uuid(id)).toList();
    final members = (await _deviceRepository.findDevicesByIds(ids)).toList();

    // TODO: support more protocols

    return Task<GroupBase>(
      id: Uuid(rpcTask.id),
      state: TaskState.created,
      approved: false,
      round: 0,
      nRounds: 6,
      context: Uint8List(0),
      info: GroupBase(req.name, members, req.threshold),
    );
  }

  void _emit(Uuid did) {
    _groupsSubjects[did].add(_groups[did].values.toList(growable: false));
  }

  @override
  Task<GroupBase> initTask(Task<GroupBase> task) => task.copyWith(
        context: ProtocolWrapper.keygen(ProtocolId.Gg18),
      );

  @override
  Future<void> finishTask(Uuid did, Task task, rpc.Task rpcTask) async {
    final id = Uint8List.fromList(rpcTask.data);
    final context = ProtocolWrapper.finish(task.context);
    _groups[did][id] = Group(id, context, task.info);
    _emit(did);
  }

  @override
  bool isSyncable(rpc.Task rpcTask) => rpcTask.type == rpc.Task_TaskType.GROUP;

  Future<Group?> findGroupById(Uuid did, List<int> id) async =>
      _groups[did][id];

  Stream<List<Group>> observeGroups(Uuid did) => _groupsSubjects[did].stream;
}
