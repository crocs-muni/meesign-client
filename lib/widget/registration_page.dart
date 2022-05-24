import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/mpc_model.dart';
import '../routes.dart';
import '../util/rnd_name_generator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController(
    text: RndNameGenerator().next(),
  );
  final _hostController = TextEditingController(
    text: 'meesign.local',
  );

  bool _working = false;
  Exception? _error;

  @override
  void initState() {
    super.initState();
    _hostController.addListener(() {
      if (_error != null) {
        setState(() {
          _error = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _working = true;
      _error = null;
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
        _error = e as Exception?;
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
                Icon(
                  Icons.lock,
                  size: 54,
                  color: Theme.of(context).colorScheme.secondary,
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
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: _hostController,
                  decoration: InputDecoration(
                    labelText: 'Coordinator address',
                    border: const OutlineInputBorder(),
                    errorText: _error == null ? null : 'Failed to register',
                  ),
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
