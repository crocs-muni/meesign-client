import 'package:drift/drift.dart';

import '../model/key_type.dart';
import '../model/protocol.dart';
import '../model/task.dart';

class Devices extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  BlobColumn get id => blob().references(Devices, #id)();
  TextColumn get host => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  BlobColumn get id => blob()();
  BlobColumn get did => blob()();
  BlobColumn get gid => blob().nullable().references(Groups, #id)();
  TextColumn get state => textEnum<TaskState>()();
  BoolColumn get approved => boolean().withDefault(const Constant(false))();
  IntColumn get round => integer().withDefault(const Constant(0))();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  BlobColumn get context => blob().nullable()();
  BlobColumn get data => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id, did};
}

class Groups extends Table {
  BlobColumn get id => blob().nullable()();
  BlobColumn get tid => blob()();
  BlobColumn get did => blob()();
  TextColumn get name => text()();
  IntColumn get threshold => integer()();
  TextColumn get protocol => textEnum<Protocol>()();
  TextColumn get keyType => textEnum<KeyType>()();
  BoolColumn get withCard => boolean().withDefault(const Constant(false))();
  BlobColumn get context => blob()();

  @override
  Set<Column> get primaryKey => {tid, did};
}

class GroupMembers extends Table {
  // task id is used instead of gid since
  // group id is only assigned after the group is established
  BlobColumn get tid => blob().references(Groups, #id)();
  BlobColumn get did => blob().references(Devices, #id)();

  @override
  Set<Column> get primaryKey => {tid, did};
}

// TODO: enforce gid refers to a group with appropriate keyType?

class Files extends Table {
  BlobColumn get tid => blob()();
  BlobColumn get did => blob()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {tid, did};
}

class Challenges extends Table {
  BlobColumn get tid => blob()();
  BlobColumn get did => blob()();
  TextColumn get name => text()();
  BlobColumn get data => blob()();

  @override
  Set<Column> get primaryKey => {tid, did};
}

class Decrypts extends Table {
  BlobColumn get tid => blob()();
  BlobColumn get did => blob()();
  TextColumn get name => text()();
  BlobColumn get data => blob()();

  @override
  Set<Column> get primaryKey => {tid, did};
}
