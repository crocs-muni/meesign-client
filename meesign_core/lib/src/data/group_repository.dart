import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/group.dart';
import '../model/key_type.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/uuid.dart';
import 'device_repository.dart';
import 'network_dispatcher.dart';
import 'task_repository.dart';

class GroupRepository extends TaskRepository<Group> {
  final NetworkDispatcher _dispatcher;
  final TaskDao _taskDao;
  final DeviceRepository _deviceRepository;

  GroupRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._taskDao,
    this._deviceRepository,
  ) : super(rpc.TaskType.GROUP, taskSource, _taskDao);

  Future<void> group(
    String name,
    List<Member> members,
    int threshold,
    Protocol protocol,
    KeyType keyType, {
    String? note,
  }) async {
    await _dispatcher.unauth.group(
      rpc.GroupRequest()
        ..deviceIds.addAll(members.expand((member) =>
            Iterable.generate(member.shares, (_) => member.device.id.bytes)))
        ..name = name
        ..threshold = threshold
        ..protocol = protocol.toNetwork()
        ..keyType = keyType.toNetwork()
        ..note = note ?? '',
    );
  }

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.GroupRequest.fromBuffer(rpcTask.request);

    final tid = rpcTask.id as Uint8List;

    final ids = req.deviceIds.map((id) => Uuid(id)).toList();
    final idShares = HashMap<Uuid, int>();
    for (final id in ids) {
      idShares.update(id, (value) => value + 1, ifAbsent: () => 1);
    }
    await _deviceRepository.getDevices(idShares.keys.toList());

    final protocol = ProtocolConversion.fromNetwork(req.protocol);
    final keyType = KeyTypeConversion.fromNetwork(req.keyType);

    // FIXME: how to move part of the transaction to TaskRepository?
    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          state: TaskState.created,
        ),
      );

      await _taskDao.insertGroup(
        db.GroupsCompanion.insert(
          tid: tid,
          did: did.bytes,
          name: req.name,
          threshold: req.threshold,
          protocol: protocol,
          keyType: keyType,
          context: Uint8List(0),
          note: Value(req.note),
        ),
      );

      await _taskDao.insertGroupMembers(
        tid,
        idShares.entries.map(
          (entry) => (did: entry.key.bytes, shares: entry.value),
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final group = await _taskDao.getGroup(did.bytes, tid: task.id);
    return task.copyWith(
      context: Value(ProtocolWrapper.keygen(
        group.protocol.toNative(),
        shares: rpcTask.data.length,
        withCard: group.withCard,
      )),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final id = Uint8List.fromList(rpcTask.data.first);
    final context = ProtocolWrapper.finish(task.context!);

    // TODO: group with task update into a transaction?
    await _taskDao.updateGroup(
      db.GroupsCompanion(
        did: Value(did.bytes),
        tid: Value(task.id),
        id: Value(id),
        context: Value(context),
      ),
    );
  }

  @override
  Future<void> approveTask(Uuid did, Uuid tid,
          {required bool agree, bool withCard = false}) =>
      taskLocks[did][tid].synchronized(() async {
        await approveTaskUnsafe(did, tid, agree);
        // TODO: throw early if withCard == true && shares > 1
        await _taskDao.updateGroup(
          db.GroupsCompanion(
            did: Value(did.bytes),
            tid: Value(tid.bytes),
            withCard: Value(withCard),
          ),
        );
      });

  @override
  Stream<List<Task<Group>>> observeTasks(Uuid did) {
    Task<Group> toModel(GroupTask gt) {
      final group = gt.group.toModel();
      return TaskConversion.fromEntity(
          gt.task, group.protocol.keygenRounds, group);
    }

    return _taskDao
        .watchGroupTasks(did.bytes)
        .map((list) => list.map(toModel).toList());
  }

  Stream<List<Group>> observeGroups(Uuid did) => observeResults(did);
}
