import 'package:drift/drift.dart';
import 'package:meesign_core/src/data/key_store.dart';
import 'package:meesign_core/src/data/network_dispatcher.dart';
import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_core/src/database/database.dart' as db;
import 'package:meesign_core/src/model/device.dart';
import 'package:meesign_core/src/util/uuid.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

class DeviceRepository {
  DeviceRepository(this._dispatcher, this._keyStore, this._deviceDao);
  final NetworkDispatcher _dispatcher;
  final KeyStore _keyStore;
  final DeviceDao _deviceDao;

  /// Creates a map of device IDs to their isLocal status from a list of devices
  Map<Uuid, bool> _createLocalDeviceMap(List<Device> devices) {
    final localDeviceMap = <Uuid, bool>{};
    for (final device in devices) {
      localDeviceMap[device.id] = device.isLocal;
    }
    return localDeviceMap;
  }

  Future<Device> register(
    String name, {
    DeviceKind kind = DeviceKind.user,
  }) async {
    final key = AuthWrapper.keygen(name);

    final resp = await _dispatcher.unauth.register(
      rpc.RegistrationRequest()
        ..name = name
        ..kind = kind.toNetwork()
        ..csr = key.csr,
    );

    final did = Uuid(resp.deviceId);
    final pkcs12 = AuthWrapper.certKeyToPkcs12(key.key, resp.certificate);
    // TODO(dev): store key in db for consistency?
    await _keyStore.store(did, pkcs12);
    if (resp.hasAuthToken()) {
      await _keyStore.storeToken(did, resp.authToken);
    }
    await _deviceDao.insertDevice(
      db.DevicesCompanion.insert(
        id: did.bytes,
        name: name,
        kind: DeviceKind.user,
        isLocal: const Value(true),
      ),
    );
    return Device(name, did, DeviceKind.user, DateTime.now(), isLocal: true);
  }

  Future<Iterable<Device>> _fetchAll() async {
    final devices = await _dispatcher.unauth.getDevices(rpc.DevicesRequest());

    return devices.devices.map(
      (device) => Device(
        device.name,
        Uuid(device.identifier),
        DeviceKindConversion.fromNetwork(device.kind),
        DateTime.fromMillisecondsSinceEpoch(
          device.lastActive.toInt() * 1000,
        ),
      ),
    );
  }

  /// Try to fetch devices with a name matching the query from the server.
  Future<Iterable<Device>> search(String query) async {
    // TODO(dev): add a cache
    final remoteDevices = await _fetchAll();
    final localDevices = await getAllLocalDevices();

    // Create a map of local devices to check isLocal flag
    final localDeviceMap = _createLocalDeviceMap(localDevices);

    return remoteDevices.where((device) {
      final matchesQuery = device.name.startsWith(query) ||
          device.name.split(' ').any((word) => word.startsWith(query));

      return matchesQuery;
    }).map((device) {
      // Preserve isLocal flag for devices that exist locally
      final isLocal = localDeviceMap[device.id] ?? false;
      return device.copyWith(isLocal: isLocal);
    });
  }

  /// Returns the requested devices. Missing devices are fetched from the
  /// server and persisted in the database.
  Future<Iterable<Device>> getDevices(List<Uuid> ids) async {
    final bIds = ids.map((id) => id.bytes);
    var locals = await _deviceDao.getDevices(bIds);

    if (locals.length != ids.length) {
      // TODO(dev): add GetDevice to server or request specific ids in DevicesRequest
      final remotes = await _fetchAll();

      // Create a map of existing local devices to preserve their isLocal flag
      final existingDevices =
          _createLocalDeviceMap(locals.map((e) => e.toModel()).toList());

      final updates =
          remotes.where((device) => ids.contains(device.id)).map((device) {
        // Preserve isLocal flag if device already exists locally
        final isLocal = existingDevices[device.id] ?? false;
        return db.DevicesCompanion.insert(
          id: device.id.bytes,
          name: device.name,
          kind: device.kind,
          isLocal: Value(isLocal),
        );
      });
      await _deviceDao.upsertDevices(updates);

      locals = await _deviceDao.getDevices(bIds);
    }

    return locals.map((e) => e.toModel());
  }

  Future<Device> getDevice(Uuid id) async {
    return (await getDevices([id])).first;
  }

  Future<List<Device>> getAllLocalDevices() async {
    final devices = await _deviceDao.getAllDevices();
    return devices.map((e) => e.toModel()).toList();
  }

  Future<void> deleteLocalDevice(Uint8List id) async {
    await _deviceDao.deleteDevice(id);
  }
}
