// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<Database> {
  $DevicesTable get devices => attachedDatabase.devices;
}
mixin _$UserDaoMixin on DatabaseAccessor<Database> {
  $DevicesTable get devices => attachedDatabase.devices;
  $UsersTable get users => attachedDatabase.users;
}
mixin _$TaskDaoMixin on DatabaseAccessor<Database> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $GroupsTable get groups => attachedDatabase.groups;
  $DevicesTable get devices => attachedDatabase.devices;
  $GroupMembersTable get groupMembers => attachedDatabase.groupMembers;
  $FilesTable get files => attachedDatabase.files;
  $ChallengesTable get challenges => attachedDatabase.challenges;
  $DecryptsTable get decrypts => attachedDatabase.decrypts;
}
