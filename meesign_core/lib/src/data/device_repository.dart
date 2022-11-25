import 'package:meesign_network/grpc.dart' as rpc;

import '../model/device.dart';
import '../util/uuid.dart';
import 'network_dispatcher.dart';

class DeviceRepository {
  final NetworkDispatcher _dispatcher;

  DeviceRepository(this._dispatcher);

  Future<Device> register(String name) async {
    final device = Device.random(name, DeviceType.app);

    final resp = await _dispatcher.unauth.register(
      rpc.RegistrationRequest(identifier: device.id.bytes, name: name),
    );

    return device;
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
