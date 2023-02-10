import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../routes.dart';
import '../sync.dart';
import '../util/chars.dart';

class RegistrationPage extends StatefulWidget {
  final String prefillName;
  final String prefillHost;

  const RegistrationPage({
    Key? key,
    this.prefillHost = '',
    this.prefillName = '',
  }) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();

  bool _working = false;
  // FIXME: use form?
  TextEditingController? _errorField;

  @override
  void initState() {
    super.initState();

    void Function() makeListener(TextEditingController controller) => () {
          if (_errorField == controller) {
            setState(() {
              _errorField = null;
            });
          }
        };

    _nameController.text = widget.prefillName;
    _hostController.text = widget.prefillHost;

    _nameController.addListener(makeListener(_nameController));
    _hostController.addListener(makeListener(_hostController));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorField = _nameController;
      });
      return;
    }

    setState(() {
      _working = true;
      _errorField = null;
    });

    final di = context.read<AppContainer>();
    final sync = context.read<Sync>();

    final host = _hostController.text;

    try {
      final dispatcher = NetworkDispatcher(host, di.keyStore,
          serverCerts: await di.caCerts, allowBadCerts: di.allowBadCerts);
      final deviceRepository = DeviceRepository(dispatcher, di.keyStore);
      final device = await deviceRepository.register(
        _nameController.text,
      );

      await di.init(host);
      di.prefRepository.setHost(host);
      di.prefRepository.setDevice(device);

      sync.init(device, [
        di.groupRepository,
        di.fileRepository,
        di.challengeRepository,
      ]);

      Navigator.pushReplacementNamed(context, Routes.home);
    } catch (e) {
      setState(() {
        _working = false;
        _errorField = _hostController;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              children: [
                const SizedBox(
                  height: 54,
                ),
                SvgPicture.asset(
                  'assets/icon_logo.svg',
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 72,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'MeeSign',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(
                  height: 32,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: const OutlineInputBorder(),
                    errorText:
                        _errorField == _nameController ? 'Invalid name' : null,
                  ),
                  textInputAction: TextInputAction.next,
                  enabled: !_working,
                  maxLength: 32,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp('[${RegExp.escape(asciiPunctuationChars)}]'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    labelText: 'Server',
                    border: const OutlineInputBorder(),
                    errorText: _errorField == _hostController
                        ? 'Failed to register'
                        : null,
                  ),
                  enabled: !_working,
                  onSubmitted: (_) => _register(),
                )
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: _working ? null : _register,
                    child: const Text('Register'),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 4,
              child: _working ? const LinearProgressIndicator() : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
