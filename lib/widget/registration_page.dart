import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../model/mpc_model.dart';
import '../routes.dart';
import '../util/chars.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController(
    text: 'meesign.local',
  );

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

    MpcModel model = context.read<MpcModel>();
    try {
      await model.register(
        _nameController.text,
        _hostController.text,
      );
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
                  color: Theme.of(context).colorScheme.secondary,
                  width: 72,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'MeeSign',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4,
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
                      RegExp('[$asciiPunctuationChars]'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    labelText: 'Coordinator address',
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
                  ElevatedButton(
                    child: const Text(
                      'REGISTER',
                    ),
                    onPressed: _working ? null : _register,
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
