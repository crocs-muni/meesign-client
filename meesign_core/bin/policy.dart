import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:meesign_core/meesign_model.dart';

extension Approval<T> on TaskRepository<T> {
  StreamSubscription<Task<T>> approveAll(Uuid did,
      {required bool Function(Task<T>) agree}) {
    return observeTasks(did)
        .expand((tasks) => tasks)
        .where((task) => !task.approved)
        .listen((task) async {
      await approveTask(did, task.id, agree: agree(task));
    });
  }
}

class DummyFileStore implements FileStore {
  @override
  String getFilePath(Uuid did, Uuid id, String name, {bool work = false}) =>
      name;

  @override
  Future<String> storeFile(Uuid did, Uuid id, String name, List<int> data,
          {bool work = false}) async =>
      getFilePath(did, id, name, work: work);
}

void printUsage(ArgParser parser, IOSink sink) {
  sink.writeln('Usage:');
  sink.writeln(parser.usage);
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'display usage information',
      negatable: false,
    )
    ..addOption(
      'host',
      help: 'address of the server',
      defaultsTo: 'localhost',
    )
    ..addOption(
      'name',
      help: 'name of the user',
      defaultsTo: 'PolicyBot',
    );

  late final ArgResults options;

  try {
    options = parser.parse(args);
  } on Exception catch (e) {
    stderr.writeln(e.toString());
    printUsage(parser, stderr);
    return;
  }
  if (options['help']) {
    printUsage(parser, stdout);
    return;
  }

  final appDir = Directory('bin/app/');

  final database = Database(appDir);
  final userDao = database.userDao;
  final userRepository = UserRepository(userDao);

  final keyStore = KeyStore(appDir);
  final dispatcher =
      NetworkDispatcher(options['host'], keyStore, allowBadCerts: true);
  final taskSource = TaskSource(dispatcher);
  final taskDao = database.taskDao;
  final deviceRepository =
      DeviceRepository(dispatcher, keyStore, database.deviceDao);
  final groupRepository =
      GroupRepository(dispatcher, taskSource, taskDao, deviceRepository);
  final fileRepository =
      FileRepository(dispatcher, taskSource, taskDao, DummyFileStore());
  final challengeRepository =
      ChallengeRepository(dispatcher, taskSource, taskDao);
  final decryptRepository = DecryptRepository(dispatcher, taskSource, taskDao);

  var user = await userRepository.getUser();
  Device device;
  if (user == null) {
    device = await deviceRepository.register(options['name'], DeviceKind.bot);
    userRepository.setUser(User(device.id, options['host']));
    print('No credentials found, registering as ${device.name}');
  } else {
    device = await deviceRepository.getDevice(user.did);
  }
  print('Logged in as ${device.name}#${device.id.encode().substring(0, 8)}');

  await groupRepository.subscribe(device.id);
  await fileRepository.subscribe(device.id);
  await challengeRepository.subscribe(device.id);
  await decryptRepository.subscribe(device.id);

  groupRepository.approveAll(device.id, agree: (_) => true);
  fileRepository.approveAll(device.id, agree: (_) => true);
  challengeRepository.approveAll(device.id, agree: (_) => true);
  decryptRepository.approveAll(device.id, agree: (_) => true);

  ProcessSignal.sigint.watch().listen((signal) {
    database.close();
    exit(0);
  });
}
