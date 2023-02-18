import 'package:drift/drift.dart';

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
