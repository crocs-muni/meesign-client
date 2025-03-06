import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../routes.dart';
import '../util/chars.dart';
import '../widget/warning_banner.dart';

enum UserStatus {
  ok,
  unregistered,
  unrecognized,
  outdated,
}

class InitPage extends StatefulWidget {
  final String prefillName;
  final String prefillHost;

  const InitPage({
    super.key,
    this.prefillHost = '',
    this.prefillName = '',
  });

  @override
  State<InitPage> createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  User? _savedUser;
  UserStatus? _status;

  Future<void> _launchHome(User user) async {
    final container = context.read<AppContainer>();

    await container.userRepository.setUser(user);
    final currentSession = container.session;
    final session = currentSession != null && currentSession.user == user ? currentSession : await container.startUserSession(user);
    session.startSync();

    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.home);
    }
  }

  Future<void> _initApp() async {
    final container = context.read<AppContainer>();
    final user = await container.userRepository.getUser();
    _savedUser = user;

    if (user == null) {
      setState(() => _status = UserStatus.unregistered);
      return;
    }

    final session = await container.startUserSession(user);

    try {
      final compatible = await session.supportServices.checkCompatibility(user.did);
      if (!compatible) {
        setState(() => _status = UserStatus.outdated);
        return;
      }
    } on UnknownDeviceException {
      setState(() => _status = UserStatus.unrecognized);
      return;
    } catch (e) {
      // likely a networking error, e.g., the user may be offline,
      // in such a case, let the user access their data
    }

    setState(() => _status = UserStatus.ok);
    await Future.delayed(const Duration(milliseconds: 400));
    _launchHome(user);
  }

  Future<void> _deleteAppData() async {
    setState(() {
      _savedUser = null;
      _status = null;
    });
    final container = context.read<AppContainer>();
    await container.recreate(deleteData: true);
    setState(() => _status = UserStatus.unregistered);
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 54,
            ),
            SvgPicture.asset(
              'assets/icon_logo.svg',
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primaryContainer,
                BlendMode.srcIn,
              ),
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
            switch (_status) {
              UserStatus.ok || null => Container(),
              UserStatus.unregistered => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: RegistrationForm(
                    prefillHost: widget.prefillHost,
                    prefillName: widget.prefillName,
                    onRegistered: _launchHome,
                  ),
                ),
              UserStatus.unrecognized => WarningBanner(
                  title: 'Unknown device',
                  text: 'The previously used server does not recognize this '
                      'device. This likely means that the server was '
                      'redeployed.\n\nYou are advised to delete your data '
                      'and start anew. Alternatively, to browse your old data, '
                      'you may try to proceed anyway. However, you will not '
                      'be able to participate in new tasks.',
                  actions: [
                    OutlinedButton(
                      onPressed: () => _launchHome(_savedUser!),
                      child: const Text('Proceed anyway'),
                    ),
                    FilledButton.tonal(
                      onPressed: _deleteAppData,
                      child: const Text('Delete data'),
                    ),
                  ],
                ),
              UserStatus.outdated => WarningBanner(
                  title: 'Unsupported server',
                  text: 'The previously used server is incompatible with this '
                      'client. The server was likely upgraded.\n\n'
                      'You are advised to install a newer client and start anew. '
                      'Alternatively, to browse your old data, you may try to '
                      'proceed anyway. However, the client may be unstable.',
                  actions: [
                    OutlinedButton(
                      onPressed: () => _launchHome(_savedUser!),
                      child: const Text('Proceed anyway'),
                    ),
                  ],
                ),
            },
            const SizedBox(
              height: 32,
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
    super.key,
    this.prefillHost = '',
    this.prefillName = '',
    required this.onRegistered,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();

  bool _working = false;
  String? _nameError;
  String? _hostError;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.prefillName;
    _hostController.text = widget.prefillHost;

    void clearErrors() {
      if (_nameError != null) setState(() => _nameError = null);
      if (_hostError != null) setState(() => _hostError = null);
    }

    _nameController.addListener(clearErrors);
    _hostController.addListener(clearErrors);
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
      setState(() => _nameError = 'Name must not be empty');
      return;
    }

    setState(() {
      _working = true;
      _nameError = null;
      _hostError = null;
    });

    final container = context.read<AppContainer>();
    final host = _hostController.text.trim();

    try {
      final session = await container.createAnonymousSession(host);

      final compatible = await session.supportServices.checkCompatibility();
      if (!compatible) {
        setState(() {
          _working = false;
          _hostError = 'Incompatible server';
        });
        return;
      }

      final device = await session.deviceRepository.register(
        _nameController.text,
      );
      widget.onRegistered(User(device.id, host));
    } catch (e) {
      setState(() {
        _working = false;
        _hostError = 'Failed to register';
      });
      rethrow;
    }
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
            errorText: _nameError,
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
            errorText: _hostError,
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
