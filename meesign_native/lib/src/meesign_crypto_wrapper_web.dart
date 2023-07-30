import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

final _webWorker = WebWorker();

typedef Message = dynamic;

class WebWorker {
  final _worker = Worker('meesign_crypto_worker.js');
  var _cmdId = 0;
  final Map<num, Completer<Message>> _outstanding = {};

  WebWorker() {
    _worker.onMessage.listen((event) {
      Message resp = event.data;
      final completer = _outstanding.remove(resp['id'])!;
      completer.complete(resp);
    });
  }

  Future<Message> send(Message cmd) {
    final id = _cmdId++;
    cmd['id'] = id;
    final completer = Completer<Message>();
    _outstanding[id] = completer;
    _worker.postMessage(cmd);
    return completer.future;
  }
}

// TODO: this is common to web and io
class ProtocolData {
  final Uint8List context, data;
  ProtocolData(this.context, this.data);
}

class ProtocolWrapper {
  static Future<Uint8List> keygen(int protoId) async {
    final resp =
        await _webWorker.send({'function': 'keygen', 'proto': protoId});
    return resp['data'];
  }

  static Future<Uint8List> init(int protoId, Uint8List group) async {
    final resp = await _webWorker
        .send({'function': 'init', 'proto': protoId, 'ctx': group});
    return resp['ctx'];
  }

  static Future<ProtocolData> advance(Uint8List context, Uint8List data) async {
    final resp = await _webWorker
        .send({'function': 'advance', 'ctx': context, 'data': data});
    return ProtocolData(resp['ctx'], resp['data']);
  }

  static Future<Uint8List> finish(Uint8List context) async {
    final resp = await _webWorker.send({'function': 'finish', 'ctx': context});
    return resp['data'];
  }
}

// TODO: ditto
class AuthKey {
  final Uint8List key, csr;
  AuthKey(this.key, this.csr);
}

class AuthWrapper {
  static AuthKey keygen(String name) {
    throw UnimplementedError();
  }

  static List<int> certKeyToPkcs12(List<int> key, List<int> cert) {
    throw UnimplementedError();
  }
}

class ElGamalWrapper {
  static Future<List<int>> encrypt(
      List<int> message, List<int> publicKey) async {
    final resp = await _webWorker
        .send({'function': 'encrypt', 'msg': message, 'key': publicKey});
    return resp['data'];
  }
}
