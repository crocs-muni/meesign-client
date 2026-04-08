import 'package:meesign_client/card/card_factory_stub.dart'
    if (dart.library.io) 'card_factory_native.dart' as card_factory;
import 'package:meesign_client/util/platform.dart';
import 'package:meesign_core/meesign_card.dart';

abstract class CardManager {
  factory CardManager() => card_factory.create() as CardManager;
  Future<void> connect();
  Future<void> disconnect();

  Future<List<Card>> poll();

  Future<List<String>> get readers;

  static bool get platformSupported =>
      PlatformGroup.isAndroid ||
      PlatformGroup.isIOS ||
      PlatformGroup.isLinux ||
      PlatformGroup.isWindows;
}
