import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../ui_constants.dart';
import '../util/chars.dart';

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
  final FocusNode _nameControllerFocus = FocusNode();
  final FocusNode _hostControllerFocus = FocusNode();

  bool _working = false;
  String? _nameError;
  String? _hostError;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.prefillName;
    _hostController.text = widget.prefillHost;

    _nameController.addListener(clearErrors);
    _hostController.addListener(clearErrors);

    _nameControllerFocus.addListener(checkFocus);
    _hostControllerFocus.addListener(checkFocus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();

    _nameController.removeListener(clearErrors);
    _hostController.removeListener(clearErrors);
    _nameControllerFocus.removeListener(checkFocus);
    _hostControllerFocus.removeListener(checkFocus);
    super.dispose();
  }

  void clearErrors() {
    if (_nameError != null) setState(() => _nameError = null);
    if (_hostError != null) setState(() => _hostError = null);
  }

  void checkFocus() {
    // Hide clear input button when not focused
    setState(() {});
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
          focusNode: _nameControllerFocus,
          decoration: InputDecoration(
            suffixIcon:
                _nameController.text == '' || !_nameControllerFocus.hasFocus
                    ? null
                    : IconButton(
                        // Icon to
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _nameController.clear();
                          });
                        },
                      ),
            labelText: 'Name',
            filled: true,
            border: const OutlineInputBorder(),
            errorText: _nameError,
          ),
          textInputAction: TextInputAction.next,
          enabled: !_working,
          maxLength: 32,
          onChanged: (_) => setState(() {}),
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp('[${RegExp.escape(asciiPunctuationChars)}]'),
            )
          ],
        ),
        const SizedBox(
          height: SMALL_GAP,
        ),
        TextField(
          controller: _hostController,
          focusNode: _hostControllerFocus,
          decoration: InputDecoration(
            suffixIcon:
                _hostController.text == '' || !_hostControllerFocus.hasFocus
                    ? SizedBox()
                    : IconButton(
                        // Icon to
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _hostController.clear();
                          });
                        },
                      ),
            labelText: 'Server',
            filled: true,
            border: const OutlineInputBorder(),
            errorText: _hostError,
          ),
          enabled: !_working,
          onSubmitted: (_) => _register(),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(
          height: 32,
        ),
        SizedBox(
          width: 200,
          height: 42,
          child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary),
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
