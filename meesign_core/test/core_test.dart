@Timeout(Duration(seconds: 180))

import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:meesign_core/meesign_core.dart';
import 'package:test/test.dart';

import 'matcher.dart';

extension ListStream<T> on Stream<Iterable<T>> {
  Future<T> firstElement() async =>
      (await firstWhere((iter) => iter.isNotEmpty)).first;

  Future<T> firstElementWhere(bool Function(T) test) =>
      map((iter) => iter.where(test)).firstElement();
}

// TODO: use stream matchers?

Future<void> approveFirst(
  TaskRepository taskRepository,
  Device d, {
  bool agree = true,
}) async {
  final t = await taskRepository.observeTasks(d.id).firstElement();
  await taskRepository.approveTask(d.id, t.id, agree: agree);
}

Future<void> approveAllFirst(
  TaskRepository taskRepository,
  Iterable<Device> devices,
) =>
    Future.wait(
      devices.map((d) => approveFirst(taskRepository, d)),
    );

const testFilePath = 'test/file.pdf';

final appDir = io.Directory('test/output');

void main() {
  late Database database;
  late KeyStore keyStore;
  late NetworkDispatcher dispatcher;
  late DeviceRepository deviceRepository;
  late GroupRepository groupRepository;
  late FileRepository fileRepository;
  late DecryptRepository decryptRepository;

  List<int>? serverCerts;
  final String? serverCertsPath = io.Platform.environment['SERVER_CERTS'];
  if (serverCertsPath != null) {
    serverCerts = io.File(serverCertsPath).readAsBytesSync();
  }

  setUp(() {
    database = Database(appDir);
    keyStore = KeyStore(appDir);
    dispatcher = NetworkDispatcher('localhost', keyStore,
        serverCerts: serverCerts, allowBadCerts: serverCerts == null);
    deviceRepository =
        DeviceRepository(dispatcher, keyStore, database.deviceDao);
    final taskSource = TaskSource(dispatcher);
    final taskDao = database.taskDao;
    groupRepository =
        GroupRepository(dispatcher, taskSource, taskDao, deviceRepository);
    final fileStore = FileStore(appDir);
    fileRepository = FileRepository(dispatcher, taskSource, taskDao, fileStore);
    decryptRepository = DecryptRepository(dispatcher, taskSource, taskDao);
  });

  Future<List<T>> testRepository<T>(
    TaskRepository<T> taskRepository,
    KeyType keyType,
    Protocol protocol, {
    required int n,
    required int t,
    required Future<void> Function(TaskRepository, Group) createTask,
  }) async {
    final ds = await Future.wait(
      [for (var i = 0; i < n; ++i) deviceRepository.register('d$i')],
    );

    await Future.wait(ds.map((d) => groupRepository.subscribe(d.id)));
    await groupRepository.group(
        '$t $n ${keyType.name} ${protocol.name}', ds, t, protocol, keyType);
    await approveAllFirst(groupRepository, ds);
    final gs = await Future.wait(
      ds.map((d) => groupRepository.observeGroups(d.id).firstElement()),
    );
    expect(gs.map((g) => g.id), allEqual);

    await Future.wait(ds.map((d) => taskRepository.subscribe(d.id)));
    await createTask(taskRepository, gs.first);
    approveAllFirst(taskRepository, ds.take(t));
    return await Future.wait(
      ds.map((d) => taskRepository.observeResults(d.id).firstElement()),
    );
  }

  Future<void> testSignPdf({required int n, required int t}) async {
    await testRepository(
      fileRepository,
      KeyType.signPdf,
      Protocol.gg18,
      n: n,
      t: t,
      createTask: (_, Group g) async {
        final data = await io.File(testFilePath).readAsBytes();
        await fileRepository.sign('test.pdf', data, g.id);
      },
    );
  }

  Future<void> testDecrypt({required int n, required int t}) async {
    final rng = Random();
    final message = List.generate(1024, (_) => rng.nextInt(256));

    final decrypts = await testRepository(
      decryptRepository,
      KeyType.decrypt,
      Protocol.elgamal,
      n: n,
      t: t,
      createTask: (_, Group g) async {
        await decryptRepository.encrypt('test secret', message, g.id);
      },
    );
    final results = [for (var d in decrypts) d.data];

    expect(results, allEqual);
    expect(results.first, equals(message));
  }

  group('sign PDF', () {
    test('2-3', () => testSignPdf(n: 3, t: 2));
    test('3-3', () => testSignPdf(n: 3, t: 3));
    test('15-20', () => testSignPdf(n: 20, t: 15), tags: 'large');
  });

  group('decrypt', () {
    test('2-3', () => testDecrypt(n: 3, t: 2));
    test('3-3', () => testDecrypt(n: 3, t: 3));
    test('15-20', () => testDecrypt(n: 20, t: 15), tags: 'large');
  });

  tearDown(() async {
    try {
      await database.close();
      appDir.deleteSync(recursive: true);
    } catch (_) {}
  });
}
