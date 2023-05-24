import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../routes.dart';
import '../sync.dart';
import '../util/chars.dart';

class InitPage extends StatefulWidget {
  final String prefillName;
  final String prefillHost;

  const InitPage({
    Key? key,
    this.prefillHost = '',
    this.prefillName = '',
  }) : super(key: key);

  @override
  State<InitPage> createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  late final Future<bool> _hasUserFuture;

  Future<void> _launchHome(User user) async {
    final di = context.read<AppContainer>();
    final sync = context.read<Sync>();

    await di.userRepository.setUser(user);
    await di.init(user.host);

    sync.init(user.did, [
      di.groupRepository,
      di.fileRepository,
      di.challengeRepository,
      di.decryptRepository,
    ]);

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  @override
  void initState() {
    super.initState();
    final di = context.read<AppContainer>();
    final userFuture = di.userRepository.getUser();
    _hasUserFuture = userFuture.then((value) => value != null);

    userFuture.then((user) async {
      if (user == null) return;
      await Future.delayed(const Duration(milliseconds: 400));
      _launchHome(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
            FutureBuilder<bool>(
              future: _hasUserFuture,
              builder: (_, snapshot) {
                if (snapshot.data ?? true) return Container();
                return RegistrationForm(
                  prefillHost: widget.prefillHost,
                  prefillName: widget.prefillName,
                  onRegistered: _launchHome,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  final String prefillName;
  final String prefillHost;
  final void Function(User) onRegistered;

  const RegistrationForm({
    Key? key,
    this.prefillHost = '',
    this.prefillName = '',
    required this.onRegistered,
  }) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
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
    // TODO: let the user cancel previous op?
    if (_working) return;

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
    final host = _hostController.text.trim();
    late final Device device;

    try {
      final dispatcher = NetworkDispatcher(host, di.keyStore,
          serverCerts: await di.caCerts, allowBadCerts: di.allowBadCerts);
      final deviceRepository =
          DeviceRepository(dispatcher, di.keyStore, di.database.deviceDao);
      device = await deviceRepository.register(
        _nameController.text,
      );
    } catch (e) {
      setState(() {
        _working = false;
        _errorField = _hostController;
      });
    }

    widget.onRegistered(User(device.id, host));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: const OutlineInputBorder(),
            errorText: _errorField == _nameController ? 'Invalid name' : null,
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
            errorText:
                _errorField == _hostController ? 'Failed to register' : null,
          ),
          enabled: !_working,
          onSubmitted: (_) => _register(),
        ),
        const SizedBox(
          height: 32,
        ),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: FilledButton(
            onPressed: _register,
            child: _working
                ? SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 4,
                    ),
                  )
                : const Text('Register'),
          ),
        ),
      ],
    );
  }
}
