import 'dart:typed_data';

abstract class Card {
  Future<Uint8List> transceive(Uint8List data);
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

  static bool get platformSupported => false;

  factory CardManager() {
    throw UnsupportedError('Platform not supported');
  }
}
