import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Devices])
class DeviceDao extends DatabaseAccessor<Database> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Future<List<Device>> getDevices(Iterable<Uint8List> ids) {
    final query = select(devices)..where((devices) => devices.id.isIn(ids));
    return query.get();
  }

  Future<List<Device>> getAllDevices() {
    final query = select(devices);
    return query.get();
  }

  Future<void> insertDevice(DevicesCompanion entity) {
    return into(devices).insert(entity, mode: InsertMode.insertOrIgnore);
  }

  Future<void> upsertDevices(Iterable<DevicesCompanion> entities) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(devices, entities));
  }

  Future<void> deleteDevice(Uint8List id) {
    return (delete(devices)..where((device) => device.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<Database> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> getUser() {
    final query = select(users);
    return query.getSingleOrNull();
  }

  Future<List<User>> getAllUsers() {
    final query = select(users);
    return query.get();
  }

  Future<void> upsertUser(UsersCompanion entity) {
    return into(users).insertOnConflictUpdate(entity);
  }

  Future<void> deleteUser(Uint8List id) {
    return (delete(users)..where((user) => user.id.equals(id))).go();
  }
}

@DriftAccessor(
  tables: [Tasks, Groups, GroupMembers, Devices, Files, Challenges, Decrypts],
)
class TaskDao extends DatabaseAccessor<Database> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<Task?> getTask(Uint8List did, Uint8List id) {
    final query = select(tasks)
      ..where((tasks) => tasks.did.equals(did) & tasks.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> upsertTask(TasksCompanion entity) {
    return into(tasks).insertOnConflictUpdate(entity);
  }

  Future<void> updateTask(TasksCompanion entity) =>
      (update(tasks)..whereSamePrimaryKey(entity)).write(entity);

  Future<void> insertGroup(GroupsCompanion entity) =>
      into(groups).insert(entity);

  Future<void> updateGroup(GroupsCompanion entity) =>
      (update(groups)..whereSamePrimaryKey(entity)).write(entity);

  Future<void> insertGroupMembers(
      Uint8List tid, Iterable<({Uint8List did, int shares})> didShares) {
    final entities = didShares.map(
      (item) => GroupMembersCompanion.insert(
        tid: tid,
        did: item.did,
        shares: item.shares,
      ),
    );
    return batch((batch) => batch.insertAll(groupMembers, entities,
        mode: InsertMode.insertOrIgnore));
  }

  Future<Group> getGroup(Uint8List did, {Uint8List? tid, Uint8List? gid}) {
    final query = select(groups)
      ..where((groups) =>
          groups.did.equals(did) &
          (tid != null ? groups.tid.equals(tid) : groups.id.equals(gid!)));
    return query.getSingle();
  }

  Future<List<({Device device, int shares})>> getGroupMembers(
      Uint8List tid) async {
    final membersQuery = select(groupMembers)
      ..where((groupMembers) => groupMembers.tid.equals(tid));

    return membersQuery
        .join([
          innerJoin(devices, groupMembers.did.equalsExp(devices.id)),
        ])
        .map(
          (result) => (
            device: result.readTable(devices),
            shares: result.read(groupMembers.shares)!
          ),
        )
        .get();
  }

  Stream<List<GroupTask>> watchGroupTasks(Uint8List did) {
    final query = select(groups)..where((group) => group.did.equals(did));
    final on = tasks.id.equalsExp(groups.tid) & tasks.did.equalsExp(groups.did);
    return query
        .join([
          innerJoin(tasks, on),
        ])
        .watch()
        .asyncMap(
          (results) => Future.wait(
            results.map(
              (result) async {
                final group = result.readTable(groups);
                return GroupTask(
                  result.readTable(tasks),
                  PopulatedGroup(group, await getGroupMembers(group.tid)),
                );
              },
            ),
          ),
        );
  }

  Future<void> insertFile(FilesCompanion entity) => into(files).insert(entity);

  Future<File> getFile(Uint8List did, Uint8List tid) => (select(files)
        ..where((file) => file.did.equals(did) & file.tid.equals(tid)))
      .getSingle();

  Stream<List<FileTask>> watchFileTasks(Uint8List did) {
    final query = select(files)..where((file) => file.did.equals(did));
    final onTask =
        tasks.id.equalsExp(files.tid) & tasks.did.equalsExp(files.did);
    final onGroup = groups.id.equalsExp(tasks.gid);
    return query.join([
      innerJoin(tasks, onTask),
      innerJoin(groups, onGroup),
    ]).asyncMap((res) async {
      final group = res.readTable(groups);
      return FileTask(
        res.readTable(tasks),
        res.readTable(files),
        PopulatedGroup(group, await getGroupMembers(group.tid)),
      );
    }).watch();
  }

  Future<void> insertChallenge(ChallengesCompanion entity) =>
      into(challenges).insert(entity);

  Future<Challenge> getChallenge(Uint8List did, Uint8List tid) =>
      (select(challenges)
            ..where((chal) => chal.did.equals(did) & chal.tid.equals(tid)))
          .getSingle();

  // TODO: is there a way to reduce the repetition?
  Stream<List<ChallengeTask>> watchChallengeTasks(Uint8List did) {
    final query = select(challenges)..where((file) => file.did.equals(did));
    final onTask = tasks.id.equalsExp(challenges.tid) &
        tasks.did.equalsExp(challenges.did);
    final onGroup = groups.id.equalsExp(tasks.gid);
    return query.join([
      innerJoin(tasks, onTask),
      innerJoin(groups, onGroup),
    ]).asyncMap((res) async {
      final group = res.readTable(groups);
      return ChallengeTask(
        res.readTable(tasks),
        res.readTable(challenges),
        PopulatedGroup(group, await getGroupMembers(group.tid)),
      );
    }).watch();
  }

  Future<void> insertDecrypt(DecryptsCompanion entity) =>
      into(decrypts).insert(entity);

  Future<Decrypt> getDecrypt(Uint8List did, Uint8List tid) => (select(decrypts)
        ..where((decrypt) => decrypt.did.equals(did) & decrypt.tid.equals(tid)))
      .getSingle();

  Future<void> updateDecrypt(DecryptsCompanion entity) =>
      (update(decrypts)..whereSamePrimaryKey(entity)).write(entity);

  // TODO: is there a way to reduce the repetition?
  Stream<List<DecryptTask>> watchDecryptTasks(Uint8List did) {
    final query = select(decrypts)..where((file) => file.did.equals(did));
    final onTask =
        tasks.id.equalsExp(decrypts.tid) & tasks.did.equalsExp(decrypts.did);
    final onGroup = groups.id.equalsExp(tasks.gid);
    return query.join([
      innerJoin(tasks, onTask),
      innerJoin(groups, onGroup),
    ]).asyncMap((res) async {
      final group = res.readTable(groups);
      return DecryptTask(
        res.readTable(tasks),
        res.readTable(decrypts),
        PopulatedGroup(group, await getGroupMembers(group.tid)),
      );
    }).watch();
  }
}

class PopulatedGroup {
  final Group group;
  final List<({Device device, int shares})> members;
  const PopulatedGroup(this.group, this.members);
}

class GroupTask {
  final Task task;
  final PopulatedGroup group;
  const GroupTask(this.task, this.group);
}

// FIXME mixin to add task, group?

class FileTask {
  final Task task;
  final PopulatedGroup group;
  final File file;
  FileTask(this.task, this.file, this.group);
}

class ChallengeTask {
  final Task task;
  final PopulatedGroup group;
  final Challenge challenge;
  ChallengeTask(this.task, this.challenge, this.group);
}

class DecryptTask {
  final Task task;
  final PopulatedGroup group;
  final Decrypt decrypt;
  DecryptTask(this.task, this.decrypt, this.group);
}
