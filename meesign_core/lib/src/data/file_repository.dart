import 'package:drift/drift.dart';
import 'package:meesign_core/src/model/group.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/file.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/uuid.dart';
import 'file_store.dart';
import 'network_dispatcher.dart';
import 'task_repository.dart';
import 'key_store.dart';

export 'file_store.dart';

class FileRepository extends TaskRepository<File> {
  static const maxFileSize = 8 * 1024 * 1024;

  final NetworkDispatcher _dispatcher;
  final KeyStore _keyStore;
  final TaskDao _taskDao;
  final FileStore _fileStore;

  FileRepository(
    this._dispatcher,
    this._keyStore,
    TaskSource taskSource,
    this._taskDao,
    this._fileStore,
  ) : super(rpc.TaskType.SIGN_PDF, taskSource, _taskDao);

  Future<void> sign(String name, List<int> data, List<int> gid) async {
    await _dispatcher.unauth.sign(
      rpc.SignRequest()
        ..groupId = gid
        ..name = name
        ..data = data,
    );
  }

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.SignRequest.fromBuffer(rpcTask.request);

    final tid = rpcTask.id as Uint8List;
    // FIXME: create random id for file?
    await _fileStore.storeFile(did, Uuid.take(tid), req.name, req.data,
        work: true);

    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          gid: Value(req.groupId as Uint8List),
          state: TaskState.created,
        ),
      );

      await _taskDao.insertFile(
        db.FilesCompanion.insert(
          tid: tid,
          did: did.bytes,
          name: req.name,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final group = await _taskDao.getGroup(did.bytes, gid: task.gid);
    return task.copyWith(
      context: Value(ProtocolWrapper.init(
        group.protocol.toNative(),
        group.context,
        group.certificates!,
        _keyStore.load(did) as Uint8List,
        shares: rpcTask.data.length,
      )),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final context = task.context;
    if (context != null) ProtocolWrapper.finish(context);
    final file = await _taskDao.getFile(did.bytes, task.id);
    await _fileStore.storeFile(
        did, Uuid.take(task.id), file.name, rpcTask.data.first);
  }

  @override
  Stream<List<Task<File>>> observeTasks(Uuid did) {
    Task<File> toModel(FileTask ft) {
      final group = ft.group.toModel();
      final path = _fileStore.getFilePath(
          did, Uuid.take(ft.task.id), ft.file.name,
          work: ft.task.state != TaskState.finished);
      final file = File(path, group);
      return TaskConversion.fromEntity(
          ft.task, group.protocol.signRounds, file);
    }

    return _taskDao
        .watchFileTasks(did.bytes)
        .map((list) => list.map((toModel)).toList());
  }

  Stream<List<File>> observeFiles(Uuid did) => observeResults(did);
}
