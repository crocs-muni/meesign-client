import '../mpc_model.dart';
import 'card.dart';
import 'iso7816.dart';

class AddCardJob implements CardJob<Cosigner> {
  const AddCardJob();

  @override
  Future<Cosigner> work(Card card) async {
    // TODO: add real impl
    final command = CommandApdu(
        Iso7816.claIso7816, Iso7816.insSelect, 0x04, 0x00, [1, 2, 3, 4]);
    final resp = await card.send(command);
    print(resp.status);
    await Future.delayed(const Duration(seconds: 1));

    // TODO: this should be done in mpc_model.dart
    return Cosigner.random('card', CosignerType.card);
  }
}
