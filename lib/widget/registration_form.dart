import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../services/settings_controller.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../util/launch_home.dart';
import '../util/set_user_login_prefereces.dart';
import 'existing_user_list.dart';

class RegistrationForm extends StatefulWidget {
  final String prefillName;
  final String prefillHost;

  const RegistrationForm({
    super.key,
    this.prefillHost = '',
    this.prefillName = '',
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final FocusNode _nameControllerFocus = FocusNode();
  final FocusNode _clearNameControllerFocus = FocusNode();
  final FocusNode _clearHostControllerFocus = FocusNode();
  final FocusNode _hostControllerFocus = FocusNode();
  final FocusNode _submitFocusNode = FocusNode();

  bool _working = false;
  String? _nameError;
  String? _hostError;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.prefillName;
    setupHostname();

    _nameController.addListener(clearErrors);
    _hostController.addListener(clearErrors);

    _nameControllerFocus.addListener(checkFocus);
    _hostControllerFocus.addListener(checkFocus);
    _submitFocusNode.addListener(checkFocus);
    _clearNameControllerFocus.addListener(checkFocus);
    _clearHostControllerFocus.addListener(checkFocus);
  }

  void setupHostname() async {
    final container = context.read<AppContainer>();
    SettingsController settingsController = container.settingsController;

    // Load last hostname user was connected to
    String? lastHostname = await settingsController.getLastHostname();

    if (lastHostname != null && lastHostname.isNotEmpty) {
      _hostController.text = lastHostname;
    } else {
      _hostController.text = widget.prefillHost;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();

    _nameController.removeListener(clearErrors);
    _hostController.removeListener(clearErrors);
    _nameControllerFocus.removeListener(checkFocus);
    _hostControllerFocus.removeListener(checkFocus);
    _submitFocusNode.removeListener(checkFocus);
    _clearHostControllerFocus.removeListener(checkFocus);
    _clearNameControllerFocus.removeListener(checkFocus);
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

      bool isNewUser = true;
      User? currentUser;

      final SettingsController settingsController =
          container.settingsController;
      String? existingUserId = await settingsController.getSavedUserId(
          _nameController.text, _hostController.text);

      if (existingUserId != null && existingUserId.isNotEmpty) {
        currentUser = await container.userRepository
            .getUser(searchedUserId: existingUserId);
        isNewUser = false;
      }

      if (currentUser == null) {
        final device = await session.deviceRepository.register(
          _nameController.text,
        );

        currentUser = User(device.id, host);
        isNewUser = true;
      }

      if (mounted) {
        updateUserSessionPreferences(
          currentUser.did.bytes,
          _nameController.text,
          _hostController.text,
          context,
        );
        launchHome(
            user: currentUser, context: context, registerNewUser: isNewUser);
      }
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
            suffixIcon: _nameController.text == '' ||
                    (!_nameControllerFocus.hasFocus &&
                        !_clearNameControllerFocus.hasFocus)
                ? null
                : IconButton(
                    focusNode: _clearNameControllerFocus,
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
          onSubmitted: (_) {
            if (_hostController.text.isEmpty) {
              _hostControllerFocus.requestFocus();
            } else {
              _register();
            }
          },
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
            suffixIcon: _hostController.text == '' ||
                    (!_hostControllerFocus.hasFocus &&
                        !_clearHostControllerFocus.hasFocus)
                ? SizedBox()
                : IconButton(
                    focusNode: _clearHostControllerFocus,
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
        _buildButtonSection()
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 42,
          child: FilledButton(
            focusNode: _submitFocusNode,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              side: _submitFocusNode.hasFocus
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      width: 5)
                  : BorderSide.none,
            ),
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
        SizedBox(height: SMALL_GAP),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExistingUserList()),
            );
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          child: Text(
            "or use an existing account",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        )
      ],
    );
  }
}
