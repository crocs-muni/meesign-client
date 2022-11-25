import 'dart:collection';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:rxdart/subjects.dart';

import '../model/file.dart';
import '../model/key_type.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';
import 'file_store.dart';
import 'group_repository.dart';
import 'network_dispatcher.dart';
import 'task_repository.dart';

import 'package:path/path.dart' as path_pkg;

export 'file_store.dart';

class FileRepository extends TaskRepository<File> {
  static const maxFileSize = 8 * 1024 * 1024;

  final NetworkDispatcher _dispatcher;
  final FileStore _fileStore;
  final GroupRepository _groupRepository;

  final DefaultMap<Uuid, BehaviorSubject<List<File>>> _filesSubjects =
      DefaultMap(HashMap(), () => BehaviorSubject.seeded([]));

  FileRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._fileStore,
    this._groupRepository,
  ) : super(taskSource);

  Future<void> sign(String path, List<int> gid) async {
    // FIXME: delegate to FileStore?
    final bytes = await io.File(path).readAsBytes();
    String basename = path_pkg.basename(path);

    await _dispatcher.unauth.sign(
      rpc.SignRequest(
        groupId: gid,
        name: basename,
        data: bytes,
      ),
    );
  }

  @override
  Future<Task<File>> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.SignRequest.fromBuffer(rpcTask.request);

    final group = await _groupRepository.findGroupById(did, req.groupId);
    if (group == null) throw StateException();
    if (group.keyType != KeyType.signPdf) throw StateException();

    final tid = Uuid(rpcTask.id);
    // FIXME: create random id for file?
    final path = await _fileStore.storeFile(did, tid, req.name, req.data);
    final file = File(path, group);

    return Task<File>(
      id: tid,
      nRounds: group.protocol.signRounds,
      context: Uint8List(0),
      info: file,
    );
  }

  @override
  Task<File> initTask(Task<File> task) => task.copyWith(
        context: ProtocolWrapper.sign(
          task.info.group.protocol.toNative(),
          task.info.group.context,
        ),
      );

  @override
  Future<void> finishTask(Uuid did, Task<File> task, rpc.Task rpcTask) async {
    if (task.context.isNotEmpty) ProtocolWrapper.finish(task.context);
    final File file = task.info;
    await _fileStore.storeFile(did, task.id, file.basename, rpcTask.data);

    final subject = _filesSubjects[did];
    subject.add([...subject.value, file]);
  }

  @override
  bool isSyncable(rpc.Task rpcTask) => rpcTask.type == rpc.TaskType.SIGN_PDF;

  Stream<List<File>> observeFiles(Uuid did) => _filesSubjects[did].stream;
}
