@Timeout(Duration(seconds: 180))
import 'dart:async';
import 'dart:io' as io;
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
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
    Future.wait(devices.map((d) => approveFirst(taskRepository, d)));

Future<void> verifyPdfSignature(String path) async {
  final res = await Process.run('pdfsig', ['-nocert', path]);
  expect(res.stdout, contains('Signature is Valid.'));
}

const testFilePath = 'test/file.pdf';

final appDir = io.Directory('test/output');

void main() {
  late Database database;
  late KeyStore keyStore;
  late NetworkDispatcher dispatcher;
  late DeviceRepository deviceRepository;
  late GroupRepository groupRepository;
  late FileRepository fileRepository;
  late ChallengeRepository challengeRepository;
  late DecryptRepository decryptRepository;

  List<int>? serverCerts;
  final String? serverCertsPath = io.Platform.environment['SERVER_CERTS'];
  if (serverCertsPath != null) {
    serverCerts = io.File(serverCertsPath).readAsBytesSync();
  }

  setUp(() {
    database = Database(appDir);
    keyStore = KeyStore(appDir);
    dispatcher = NetworkDispatcher(
      'localhost',
      keyStore,
      serverCerts: serverCerts,
      allowBadCerts: serverCerts == null,
    );
    deviceRepository = DeviceRepository(
      dispatcher,
      keyStore,
      database.deviceDao,
    );
    final taskSource = TaskSource(dispatcher);
    final taskDao = database.taskDao;
    groupRepository = GroupRepository(
      dispatcher,
      keyStore,
      taskSource,
      taskDao,
      deviceRepository,
    );
    final fileStore = FileStore(appDir);
    fileRepository = FileRepository(
      dispatcher,
      keyStore,
      taskSource,
      taskDao,
      fileStore,
    );
    challengeRepository = ChallengeRepository(
      dispatcher,
      keyStore,
      taskSource,
      taskDao,
    );
    decryptRepository = DecryptRepository(
      dispatcher,
      keyStore,
      taskSource,
      taskDao,
    );
  });

  Future<List<T>> testRepository<T>(
    TaskRepository<T> taskRepository,
    KeyType keyType,
    Protocol protocol, {
    int? n,
    List<int>? shares,
    required int t,
    required Future<void> Function(TaskRepository, Group) createTask,
  }) async {
    n ??= shares!.length;
    shares ??= List.filled(n, 1);

    final ds = await Future.wait([
      for (var i = 0; i < n; ++i) deviceRepository.register('d$i'),
    ]);

    await Future.wait(ds.map((d) => groupRepository.subscribe(d.id)));
    final members = [for (final (i, d) in ds.indexed) Member(d, shares[i])];
    final sharesDesc = shares.any((value) => value > 1)
        ? shares.join(' ')
        : shares.sum.toString();
    await groupRepository.group(
      '$t of $sharesDesc ${keyType.name} ${protocol.name}',
      members,
      t,
      protocol,
      keyType,
    );
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

  Future<void> testSignPdf({int? n, List<int>? shares, required int t}) async {
    final files = await testRepository(
      fileRepository,
      KeyType.signPdf,
      Protocol.gg18,
      n: n,
      shares: shares,
      t: t,
      createTask: (_, Group g) async {
        final data = await io.File(testFilePath).readAsBytes();
        await fileRepository.sign('test.pdf', data, g.id);
      },
    );

    for (var file in files) {
      await verifyPdfSignature(file.path);
    }
  }

  Future<void> testSignChallenge(
    Protocol protocol, {
    int? n,
    List<int>? shares,
    required int t,
  }) async {
    final rng = Random();
    final message = List.generate(1024, (_) => rng.nextInt(256));

    await testRepository(
      challengeRepository,
      KeyType.signChallenge,
      protocol,
      n: n,
      shares: shares,
      t: t,
      createTask: (_, Group g) async {
        await challengeRepository.sign('test challenge', message, g.id);
      },
    );

    // TODO: verify signatures
  }

  Future<void> testDecrypt({int? n, List<int>? shares, required int t}) async {
    final rng = Random();
    final message = List.generate(1024, (_) => rng.nextInt(256));

    final decrypts = await testRepository(
      decryptRepository,
      KeyType.decrypt,
      Protocol.elgamal,
      n: n,
      shares: shares,
      t: t,
      createTask: (_, Group g) async {
        await decryptRepository.encrypt(
          'test secret',
          MimeType.octetStream,
          message,
          g.id,
        );
      },
    );
    final results = [for (var d in decrypts) d.data];

    expect(results, allEqual);
    expect(results.first, equals(message));
  }

  group('sign PDF', () {
    test('2-3', () => testSignPdf(n: 3, t: 2));
    test('3-3', () => testSignPdf(n: 3, t: 3));
    test('3-[1, 2, 3]', () => testSignPdf(shares: [1, 2, 3], t: 3));
    test('15-20', () => testSignPdf(n: 20, t: 15), tags: 'large');
  });

  group('challenge', () {
    group('gg18', () {
      test('2-3', () => testSignChallenge(Protocol.gg18, n: 3, t: 2));
      test('3-3', () => testSignChallenge(Protocol.gg18, n: 3, t: 3));
      test(
        '3-[1, 2, 3]',
        () => testSignChallenge(Protocol.gg18, shares: [1, 2, 3], t: 3),
      );
      test(
        '15-20',
        () => testSignChallenge(Protocol.gg18, n: 20, t: 15),
        tags: 'large',
      );
    });
    group('frost', () {
      test('2-3', () => testSignChallenge(Protocol.frost, n: 3, t: 2));
      test('3-3', () => testSignChallenge(Protocol.frost, n: 3, t: 3));
      test(
        '3-[1, 2, 3]',
        () => testSignChallenge(Protocol.frost, shares: [1, 2, 3], t: 3),
      );
      test(
        '15-20',
        () => testSignChallenge(Protocol.frost, n: 20, t: 15),
        tags: 'large',
      );
    });
    group('musig2', () {
      test('2-2', () => testSignChallenge(Protocol.musig2, n: 2, t: 2));
      test('3-3', () => testSignChallenge(Protocol.musig2, n: 3, t: 3));
      test(
        '15-15',
        () => testSignChallenge(Protocol.musig2, n: 15, t: 15),
        tags: 'large',
      );
    });
  });

  group('decrypt', () {
    test('2-3', () => testDecrypt(n: 3, t: 2));
    test('3-3', () => testDecrypt(n: 3, t: 3));
    test('3-[1, 2, 3]', () => testDecrypt(shares: [1, 2, 3], t: 3));
    test('15-20', () => testDecrypt(n: 20, t: 15), tags: 'large');
  });

  tearDown(() async {
    try {
      // FIXME: not all db updates are written when the test finishes
      await Future.delayed(const Duration(milliseconds: 100));
      await database.close();
      appDir.deleteSync(recursive: true);
    } catch (_) {}
  });
}
