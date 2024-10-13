import 'dart:typed_data';

class CommandApdu {
  final _builder = BytesBuilder();

  CommandApdu(
    int cla,
    int ins, {
    int p1 = 0,
    int p2 = 0,
    List<int>? data,
  }) {
    _builder.add([cla, ins, p1, p2]);
    if (data != null) {
      if (data.isEmpty) return;
      _builder.addByte(data.length);
      _builder.add(data);
    }
  }

  Uint8List takeBytes() => _builder.takeBytes();
}

class ResponseApdu {
  final Uint8List _rawData;

  ResponseApdu(Uint8List data) : _rawData = data;

  Uint8List get data =>
      Uint8List.view(_rawData.buffer, 0, _rawData.lengthInBytes - 2)
          .asUnmodifiableView();

  int get status => (_rawData[_rawData.length - 2] << 8) + _rawData.last;
}
