import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
import 'package:provider/provider.dart';

import 'dart:io';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({Key? key}) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  int _threshold = 1;
  final List<Cosigner> _members = [];
  final _nameController = TextEditingController();
  bool _creatable = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkCreatable);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Iterable<Widget> get _memberChips sync* {
    for (final Cosigner member in _members) {
      final icon =
          member.type == CosignerType.peer ? Icons.person : Icons.contactless;
      yield InputChip(
        label: Text(member.name),
        avatar: CircleAvatar(
          child: Icon(icon),
        ),
        onDeleted: () {
          setState(() {
            _members.remove(member);
          });
        },
      );
    }
  }

  void _checkCreatable() {
    setState(() {
      _creatable = _members.length >= 2 && _nameController.text.isNotEmpty;
    });
  }

  void _selectSearchedPeer() async {
    final peer = await Navigator.pushNamed(context, '/new_group/search');
    if (peer is! Cosigner || _members.contains(peer)) return;
    setState(() {
      _members.add(peer);
      _checkCreatable();
    });
  }

  void _finishCreate() {
    final model = context.read<MpcModel>();
    model.addGroup(_nameController.text, _members, _threshold);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _creatable ? _finishCreate : null,
            style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary),
            child: const Text('CREATE'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Group name',
              border: OutlineInputBorder(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Divider(),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.qr_code),
                        title: const Text('Scan QR code'),
                        enabled: Platform.isAndroid || Platform.isIOS,
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.contactless_outlined),
                        title: const Text('Add NFC card'),
                        enabled: Platform.isAndroid || Platform.isIOS,
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const SimpleDialog(
                                  children: [
                                    Icon(
                                      Icons.contactless_outlined,
                                      color: Colors.amber,
                                      size: 64,
                                    ),
                                    Text(
                                      'Hold a card near the back of the device',
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                );
                              });
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.search),
                        title: const Text('Search peer'),
                        onTap: _selectSearchedPeer,
                      ),
                    ],
                  );
                },
              );
            },
            label: const Text('New member'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _memberChips.toList(),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Divider(),
          ),
          Row(
            children: [
              const Icon(Icons.info),
              const SizedBox(width: 16),
              Flexible(
                child: _members.length > 1
                    ? Text(
                        'Threshold: $_threshold out of ${_members.length} members '
                        'will be required to sign a document')
                    : const Text('Add more members to set threshold'),
              ),
            ],
          ),
          _members.length > 1
              ? Slider(
                  value: _threshold.toDouble(),
                  min: 1,
                  max: _members.length.toDouble(),
                  divisions: _members.length - 1,
                  label: _threshold.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _threshold = value.toInt();
                    });
                  },
                )
              : const Slider(value: 0, onChanged: null),
        ],
      ),
    );
  }
}
