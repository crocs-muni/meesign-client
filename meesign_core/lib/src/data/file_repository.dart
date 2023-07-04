import 'dart:io' as io;
import 'dart:typed_data';

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

import 'package:path/path.dart' as path_pkg;

export 'file_store.dart';

class FileRepository extends TaskRepository<File> {
  static const maxFileSize = 8 * 1024 * 1024;

  final NetworkDispatcher _dispatcher;
  final TaskDao _taskDao;
  final FileStore _fileStore;

  FileRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._taskDao,
    this._fileStore,
  ) : super(taskSource, _taskDao);

  Future<void> sign(String path, List<int> gid) async {
    // FIXME: delegate to FileStore?
    final bytes = await io.File(path).readAsBytes();
    String basename = path_pkg.basename(path);

    await _dispatcher.unauth.sign(
      rpc.SignRequest()
        ..groupId = gid
        ..name = basename
        ..data = bytes,
    );
  }

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.SignRequest.fromBuffer(rpcTask.request);

    final tid = rpcTask.id as Uint8List;
    // FIXME: create random id for file?
    await _fileStore.storeFile(did, Uuid.take(tid), req.name, req.data);

    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          state: TaskState.created,
          // FIXME: make nullable?
          context: Uint8List(0),
        ),
      );

      await _taskDao.insertFile(
        db.FilesCompanion.insert(
          tid: tid,
          did: did.bytes,
          gid: req.groupId as Uint8List,
          name: req.name,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task) async {
    final file = await _taskDao.getFile(did.bytes, task.id);
    final group = await _taskDao.getGroup(did.bytes, gid: file.gid);
    return task.copyWith(
      context: ProtocolWrapper.init(
        group.protocol.toNative(),
        group.context,
      ),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    if (task.context.isNotEmpty) ProtocolWrapper.finish(task.context);
    final file = await _taskDao.getFile(did.bytes, task.id);
    await _fileStore.storeFile(
        did, Uuid.take(task.id), file.name, rpcTask.data);
  }

  @override
  bool isSyncable(rpc.Task rpcTask) => rpcTask.type == rpc.TaskType.SIGN_PDF;

  @override
  Stream<List<Task<File>>> observeTasks(Uuid did) {
    Task<File> toModel(FileTask ft) {
      final group = ft.group.toModel();
      final path =
          _fileStore.getFilePath(did, Uuid.take(ft.task.id), ft.file.name);
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
