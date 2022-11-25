import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:meta/meta.dart';

extension Range<T> on Comparable<T> {
  bool within(T a, T b) => compareTo(a) >= 0 && compareTo(b) <= 0;
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
  Future<String> getFilePath(Uuid did, Uuid id, String name) async => name;

  @override
  Future<String> storeFile(
          Uuid did, Uuid id, String name, List<int> data) async =>
      getFilePath(did, id, name);
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
      defaultsTo: 'Time Policy Enforcer',
    )
    ..addOption(
      'from',
      valueHelp: '9:00',
      mandatory: true,
    )
    ..addOption(
      'to',
      valueHelp: '17:00',
      mandatory: true,
    );

  late final ArgResults options;
  late final Time from, to;

  try {
    options = parser.parse(args);
    from = Time.parse(options['from']);
    to = Time.parse(options['to']);
  } on Exception catch (e) {
    stderr.writeln(e.toString());
    printUsage(parser, stderr);
    return;
  }
  if (options['help']) {
    printUsage(parser, stdout);
    return;
  }

  final keyStore = KeyStore();
  final dispatcher =
      NetworkDispatcher(options['host'], keyStore, allowBadCerts: true);
  final taskSource = TaskSource(dispatcher);
  final deviceRepository = DeviceRepository(dispatcher, keyStore);
  final groupRepository =
      GroupRepository(dispatcher, taskSource, deviceRepository);
  final fileRepository =
      FileRepository(dispatcher, taskSource, DummyFileStore(), groupRepository);
  final challengeRepository = ChallengeRepository(taskSource, groupRepository);

  final device = await deviceRepository.register(options['name']);
  print('Registered as ${device.name}');

  await groupRepository.subscribe(device.id);
  await fileRepository.subscribe(device.id);
  await challengeRepository.subscribe(device.id);

  print('Approving from $from to $to');
  groupRepository.approveAll(device.id, agree: (_) => true);
  fileRepository.approveAll(device.id, agree: (task) {
    bool ok = Time.now().within(from, to);
    print('Checking time for "${task.info.path}": ${ok ? 'OK' : 'NOK'}');
    return ok;
  });
  challengeRepository.approveAll(device.id, agree: (task) {
    bool ok = Time.now().within(from, to);
    print('Checking time for "${task.info.name}": ${ok ? 'OK' : 'NOK'}');
    return ok;
  });
}
