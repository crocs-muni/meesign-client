import 'package:drift/drift.dart';

class Devices extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
