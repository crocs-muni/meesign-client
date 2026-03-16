// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<Database> {
  $DevicesTable get devices => attachedDatabase.devices;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db.attachedDatabase, _db.devices);
}

mixin _$UserDaoMixin on DatabaseAccessor<Database> {
  $DevicesTable get devices => attachedDatabase.devices;
  $UsersTable get users => attachedDatabase.users;
  UserDaoManager get managers => UserDaoManager(this);
}

class UserDaoManager {
  final _$UserDaoMixin _db;
  UserDaoManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db.attachedDatabase, _db.devices);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
}

mixin _$TaskDaoMixin on DatabaseAccessor<Database> {
  $GroupsTable get groups => attachedDatabase.groups;
  $TasksTable get tasks => attachedDatabase.tasks;
  $DevicesTable get devices => attachedDatabase.devices;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  $FilesTable get files => attachedDatabase.files;
  $ChallengesTable get challenges => attachedDatabase.challenges;
  $DecryptsTable get decrypts => attachedDatabase.decrypts;
  $ObservedTasksTable get observedTasks => attachedDatabase.observedTasks;
  TaskDaoManager get managers => TaskDaoManager(this);
}

class TaskDaoManager {
  final _$TaskDaoMixin _db;
  TaskDaoManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db.attachedDatabase, _db.groups);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db.attachedDatabase, _db.devices);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db.attachedDatabase, _db.groupMembers);
  $$FilesTableTableManager get files =>
      $$FilesTableTableManager(_db.attachedDatabase, _db.files);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db.attachedDatabase, _db.challenges);
  $$DecryptsTableTableManager get decrypts =>
      $$DecryptsTableTableManager(_db.attachedDatabase, _db.decrypts);
  $$ObservedTasksTableTableManager get observedTasks =>
      $$ObservedTasksTableTableManager(_db.attachedDatabase, _db.observedTasks);
}
