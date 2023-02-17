import '../util/uuid.dart';

class PrefRepository {
  String? _host;
  Uuid? _did;

  Future<String?> getHost() async => _host;
  Future<Uuid?> getDid() async => _did;

  void setHost(String host) => _host = host;
  void setDid(Uuid did) => _did = did;
}
