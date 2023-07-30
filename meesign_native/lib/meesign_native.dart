library meesign_native;

export 'src/generated/protocol_id.dart';
export 'src/meesign_crypto_wrapper.dart'
    if (dart.library.html) 'src/meesign_crypto_wrapper_web.dart'
    show ProtocolWrapper, AuthWrapper, ElGamalWrapper;
