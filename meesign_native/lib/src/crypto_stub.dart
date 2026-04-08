import 'package:meesign_native/src/crypto_interface.dart';

export 'package:meesign_native/src/crypto_interface.dart';

Future<CryptoInterface> createCryptoInstance() async {
  throw UnsupportedError(
    'Cannot create CryptoInterface: '
    'no implementation available for this platform.',
  );
}
