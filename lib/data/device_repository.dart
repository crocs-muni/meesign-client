import '../grpc/generated/mpc.pbgrpc.dart' as rpc;
import '../model/device.dart';
import '../util/uuid.dart';

class DeviceRepository {
  final rpc.MPCClient _rpcClient;

  DeviceRepository(this._rpcClient);

  Future<Device> register(String name) async {
    final device = Device.random(name, DeviceType.app);

    await _rpcClient.register(
      rpc.RegistrationRequest(identifier: device.id.bytes, name: name),
    );

    return device;
  }

  Future<Iterable<Device>> getDevices() async {
    final devices = await _rpcClient.getDevices(rpc.DevicesRequest());

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
