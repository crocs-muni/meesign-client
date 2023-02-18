import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:rxdart/subjects.dart';

import '../model/device.dart';
import '../model/group.dart';
import '../model/key_type.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';
import 'device_repository.dart';
import 'network_dispatcher.dart';
import 'task_repository.dart';

// TODO: hide the group context from the outside world?

class GroupRepository extends TaskRepository<Group> {
  final NetworkDispatcher _dispatcher;
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

  GroupRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._deviceRepository,
  ) : super(taskSource);

  Future<void> group(
    String name,
    List<Device> members,
    int threshold,
    Protocol protocol,
    KeyType keyType,
  ) async {
    await _dispatcher.unauth.group(
      rpc.GroupRequest(
        deviceIds: members.map((m) => m.id.bytes),
        name: name,
        threshold: threshold,
        protocol: protocol.toNetwork(),
        keyType: keyType.toNetwork(),
      ),
    );
  }

  @override
  Future<Task<Group>> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.GroupRequest.fromBuffer(rpcTask.request);

    final ids = req.deviceIds.map((id) => Uuid(id)).toList();
    final members = (await _deviceRepository.findDevicesByIds(ids)).toList();
    final protocol = ProtocolConversion.fromNetwork(req.protocol);
    final keyType = KeyTypeConversion.fromNetwork(req.keyType);

    return Task<Group>(
      id: Uuid(rpcTask.id),
      nRounds: protocol.keygenRounds,
      context: Uint8List(0),
      info: Group([], req.name, members, req.threshold, protocol, keyType,
          Uint8List(0)),
    );
  }

  void _emit(Uuid did) {
    _groupsSubjects[did].add(_groups[did].values.toList(growable: false));
  }

  @override
  Task<Group> initTask(Task<Group> task) => task.copyWith(
        context: ProtocolWrapper.keygen(task.info.protocol.toNative()),
      );

  @override
  Future<void> finishTask(Uuid did, Task<Group> task, rpc.Task rpcTask) async {
    final id = Uint8List.fromList(rpcTask.data);
    final context = ProtocolWrapper.finish(task.context);
    final group = task.info;
    _groups[did][id] = Group(id, group.name, group.members, group.threshold,
        group.protocol, group.keyType, context);
    _emit(did);
  }

  @override
  bool isSyncable(rpc.Task rpcTask) => rpcTask.type == rpc.TaskType.GROUP;

  Future<Group?> findGroupById(Uuid did, List<int> id) async =>
      _groups[did][id];

  Stream<List<Group>> observeGroups(Uuid did) => _groupsSubjects[did].stream;
}
