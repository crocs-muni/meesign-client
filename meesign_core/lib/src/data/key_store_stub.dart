import 'package:meesign_core/meesign_data.dart';

class KeyStore {
  // Matches native KeyStore constructor signature for conditional imports.
  // ignore: avoid_unused_constructor_parameters
  KeyStore([String? dirPath]);

  Future<void> store(Uuid did, List<int> key) async {
    throw UnsupportedError('KeyStore not available on this platform.');
  }

  List<int> load(Uuid did) {
    throw UnsupportedError('KeyStore not available on this platform.');
  }

  Future<void> storeToken(Uuid did, String token) async {
    throw UnsupportedError('KeyStore not available on this platform.');
  }

  String? loadToken(Uuid did) {
    throw UnsupportedError('KeyStore not available on this platform.');
  }
}
