import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../model/device.dart';
import '../util/uuid.dart';
import 'key_store.dart';
import 'network_dispatcher.dart';

class DeviceRepository {
  final NetworkDispatcher _dispatcher;
  final KeyStore _keyStore;

  DeviceRepository(this._dispatcher, this._keyStore);

  Future<Device> register(String name) async {
    final key = AuthWrapper.keygen(name);

    final resp = await _dispatcher.unauth.register(
      rpc.RegistrationRequest(
        name: name,
        csr: key.csr,
      ),
    );

    final did = Uuid(resp.deviceId);
    final pkcs12 = AuthWrapper.certKeyToPkcs12(key.key, resp.certificate);
    _keyStore.store(did, pkcs12);
    return Device(name, did, DeviceType.app, DateTime.now());
  }

  Future<Iterable<Device>> getDevices() async {
    final devices = await _dispatcher.unauth.getDevices(rpc.DevicesRequest());

    return devices.devices.map(
      (device) => Device(
        device.name,
        Uuid(device.identifier),
        DeviceType.app,
        DateTime.fromMillisecondsSinceEpoch(
          device.lastActive.toInt() * 1000,
        ),
      ),
    );
  }

  Future<Iterable<Device>> findDeviceByName(String query) async {
    return (await getDevices()).where((device) =>
        device.name.startsWith(query) ||
        device.name.split(' ').any(
              (word) => word.startsWith(query),
            ));
  }

  Future<Iterable<Device>> findDevicesByIds(List<Uuid> ids) async {
    // TODO: add GetDevice to server or request specific ids in DevicesRequest
    final devices = await getDevices();
    return ids.map((id) => devices.firstWhere((device) => device.id == id));
  }
}
