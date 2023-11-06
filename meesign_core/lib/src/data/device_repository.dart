import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/device.dart';
import '../util/uuid.dart';
import 'key_store.dart';
import 'network_dispatcher.dart';

class DeviceRepository {
  final NetworkDispatcher _dispatcher;
  final KeyStore _keyStore;
  final DeviceDao _deviceDao;

  DeviceRepository(this._dispatcher, this._keyStore, this._deviceDao);

  Future<Device> register(String name) async {
    final key = AuthWrapper.keygen(name);

    final resp = await _dispatcher.unauth.register(
      rpc.RegistrationRequest()
        ..name = name
        ..csr = key.csr,
    );

    final did = Uuid(resp.deviceId);
    final pkcs12 = AuthWrapper.certKeyToPkcs12(key.key, resp.certificate);
    // TODO: store key in db for consistency?
    await _keyStore.store(did, pkcs12);
    await _deviceDao.insertDevice(
      db.DevicesCompanion.insert(id: did.bytes, name: name),
    );
    return Device(name, did, DateTime.now());
  }

  Future<Iterable<Device>> _fetchAll() async {
    final devices = await _dispatcher.unauth.getDevices(rpc.DevicesRequest());

    return devices.devices.map(
      (device) => Device(
        device.name,
        Uuid(device.identifier),
        DateTime.fromMillisecondsSinceEpoch(
          device.lastActive.toInt() * 1000,
        ),
      ),
    );
  }

  /// Try to fetch devices with a name matching the query from the server.
  Future<Iterable<Device>> search(String query) async {
    // TODO: add a cache
    return (await _fetchAll()).where((device) =>
        device.name.startsWith(query) ||
        device.name.split(' ').any(
              (word) => word.startsWith(query),
            ));
  }

  /// Returns the requested devices. Missing devices are fetched from the
  /// server and persisted in the database.
  Future<Iterable<Device>> getDevices(List<Uuid> ids) async {
    final bIds = ids.map((id) => id.bytes);
    var locals = await _deviceDao.getDevices(bIds);

    if (locals.length != ids.length) {
      // TODO: add GetDevice to server or request specific ids in DevicesRequest
      final remotes = await _fetchAll();
      final updates = remotes
          .where((device) => ids.contains(device.id))
          .map((device) => db.DevicesCompanion.insert(
                id: device.id.bytes,
                name: device.name,
              ));
      await _deviceDao.upsertDevices(updates);

      locals = await _deviceDao.getDevices(bIds);
    }

    return locals.map((e) => e.toModel());
  }

  Future<Device> getDevice(Uuid id) async {
    return (await getDevices([id])).first;
  }
}
