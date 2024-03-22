import 'dart:async';
import 'dart:io' hide File;
import 'dart:io' as io;
import 'dart:convert';

import 'package:args/args.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:meta/meta.dart';

extension Range<T> on Comparable<T> {
  bool within(T a, T b) => compareTo(a) >= 0 && compareTo(b) <= 0;
  bool outside(T a, T b) => compareTo(a) <= 0 || compareTo(b) >= 0;
}

@immutable
class Time implements Comparable<Time> {
  final int hour;
  final int minute;

  const Time({required this.hour, required this.minute});

  factory Time.now() {
    final now = DateTime.now();
    return Time(hour: now.hour, minute: now.minute);
  }

  static Time parse(String string) {
    final parts = string.trim().split(':');
    if (parts.length != 2) throw FormatException('Invalid time format');

    final hour = int.parse(parts[0]);
    if (!hour.within(0, 23)) throw FormatException('Hour out of range');
    final minute = int.parse(parts[1]);
    if (!minute.within(0, 59)) throw FormatException('Minute out of range');

    return Time(hour: hour, minute: minute);
  }

  @override
  String toString() {
    String pad(num n) => n.toString().padLeft(2, '0');
    return '${pad(hour)}:${pad(minute)}';
  }

  @override
  int compareTo(Time other) {
    int encode(Time t) => 60 * t.hour + t.minute;
    return encode(this) - encode(other);
  }
}

Group getGroup<T>(Task<T> task) {
  final info = task.info;
  if (info is Challenge) return info.group;
  if (info is Decrypt) return info.group;
  if (info is File) return info.group;
  if (info is Group) return info;
  throw ArgumentError('Unknown task type');
}

String getName<T>(Task<T> task) {
  final info = task.info;
  if (info is Challenge) return info.name;
  if (info is Decrypt) return info.name;
  if (info is File) return info.path;
  if (info is Group) return info.name;
  throw ArgumentError('Unknown task type');
}

extension TaskDecision<T> on TaskRepository<T> {
  StreamSubscription<Task<T>> approveAll(Uuid did) {
    return observeTasks(did)
        .expand((tasks) => tasks)
        .where((task) => !task.approved)
        .listen((task) async {
      await approveTask(did, task.id, agree: true);
    });
  }

  void decide(Uuid did, Map<String, dynamic> basePolicy) async {
    final tasks = await observeTasks(did).first;

    for (var task in tasks) {
      if (task.approved) continue;

      final group = getGroup(task);
      late final Map<String, dynamic> extPolicy;
      try {
        extPolicy = jsonDecode(group.note ?? '{}');
      } on Exception {
        extPolicy = {};
      }

      final result = evalPolicy(basePolicy, extPolicy, task);
      if (result != null) {
        if (result) {
          print('Approved task: ${getName(task)} $extPolicy');
        } else {
          print('Declined task: ${getName(task)} $extPolicy');
        }
        await approveTask(did, task.id, agree: result);
      }
    }
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

bool? evalPolicy<T>(Map<String, dynamic> basePolicy,
    Map<String, dynamic> extPolicy, Task<T> task) {
  var policy = basePolicy;
  if (policy["overridable"] ?? true) {
    policy = {...basePolicy, ...extPolicy};
  }
  var result = true;

  if (policy["fail"] ?? false) {
    result = false;
  }

  try {
    final after = Time.parse(policy["after"] ?? "00:00");
    final before = Time.parse(policy["before"] ?? "23:59");
    if (after.compareTo(before) > 0) {
      result = result && Time.now().outside(before, after);
    } else {
      result = result && Time.now().within(after, before);
    }
  } on Exception catch (e) {
    print("Error parsing after: $e");
  }

  if (result) {
    return true;
  }
  if (policy["decline"] ?? false) {
    return false;
  }
  return null;
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
    )
    ..addOption(
      'policy',
      help: 'path to the policy file',
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

  var policyData = <String, dynamic>{};
  if (options['policy'] != null) {
    try {
      policyData = jsonDecode(io.File(options['policy']).readAsStringSync());
    } on Exception catch (e) {
      stderr.writeln('Failed to read policy file: $e');
      return;
    }
  }

  final appDir = Directory('app/');

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
    device = await deviceRepository.register(
      options['name'],
      kind: DeviceKind.bot,
    );
    userRepository.setUser(User(device.id, options['host']));
    print('No credentials found, registering as ${device.name}');
  } else {
    device = await deviceRepository.getDevice(user.did);
  }
  print('Logged in as ${device.name}#${device.id.encode().substring(0, 4)}');
  print('Base policy: $policyData');

  await groupRepository.subscribe(device.id);
  await fileRepository.subscribe(device.id);
  await challengeRepository.subscribe(device.id);
  await decryptRepository.subscribe(device.id);

  groupRepository.approveAll(device.id);

  Timer.periodic(Duration(seconds: 1), (_) {
    fileRepository.decide(device.id, policyData);
  });
  Timer.periodic(Duration(seconds: 1), (_) {
    challengeRepository.decide(device.id, policyData);
  });
  Timer.periodic(Duration(seconds: 1), (_) {
    decryptRepository.decide(device.id, policyData);
  });

  ProcessSignal.sigint.watch().listen((signal) {
    database.close();
    exit(0);
  });
}
