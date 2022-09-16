import '../model/device.dart';

class PrefRepository {
  String? _host;
  Device? _device;

  Future<String?> getHost() async => _host;
  Future<Device?> getDevice() async => _device;

  void setHost(String host) => _host = host;
  void setDevice(Device device) => _device = device;
}
