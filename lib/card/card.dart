import 'dart:io';
import 'dart:typed_data';

import 'nfc_card.dart';
// import 'pcsc_card.dart';

class CommandApdu {
  final _builder = BytesBuilder();

  CommandApdu(
    int cla,
    int ins, [
    int p1 = 0,
    int p2 = 0,
    List<int>? data,
  ]) {
    _builder.add([cla, ins, p1, p2]);
    if (data != null) _builder.add(data);
  }

  void add(List<int> data) => _builder.add(data);

  Uint8List takeBytes() => _builder.takeBytes();
}

class ResponseApdu {
  final Uint8List _rawData;

  ResponseApdu(Uint8List data) : _rawData = data;

  UnmodifiableUint8ListView get data => UnmodifiableUint8ListView(
      Uint8List.view(_rawData.buffer, 0, _rawData.lengthInBytes - 2));

  int get status => (_rawData[_rawData.length - 2] << 8) + _rawData.last;
}

abstract class Card {
  Future<Uint8List> transceive(Uint8List data);
  Future<ResponseApdu> send(CommandApdu command) async {
    final data = await transceive(command.takeBytes());
    return ResponseApdu(data);
  }

  Future<void> disconnect();
}

abstract class CardJob<T> {
  Future<T> work(Card card);
}

abstract class CardManager {
  Future<void> connect();
  Future<void> disconnect();

  Future<List<Card>> poll();

  Future<List<String>> get readers;

  static bool get platformSupported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows;

  factory CardManager() {
    if (Platform.isAndroid || Platform.isIOS) {
      return NfcCardManager();
    }
    if (Platform.isLinux || Platform.isWindows) {
      // return PcscCardManager();
    }
    throw UnsupportedError('Platform not supported');
  }
}
