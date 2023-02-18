import 'package:drift/drift.dart';

import 'database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Devices])
class DeviceDao extends DatabaseAccessor<Database> with _$DeviceDaoMixin {
  DeviceDao(Database db) : super(db);

  Future<List<Device>> getDevices(Iterable<Uint8List> ids) {
    final query = select(devices)..where((devices) => devices.id.isIn(ids));
    return query.get();
  }

  Future<void> insertDevice(DevicesCompanion entity) {
    return into(devices).insert(entity, mode: InsertMode.insertOrIgnore);
  }

  Future<void> upsertDevices(Iterable<DevicesCompanion> entities) async {
    await batch((batch) => batch.insertAllOnConflictUpdate(devices, entities));
  }
}
