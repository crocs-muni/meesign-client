import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({Key? key}) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  int _threshold = 1;
  final List _members = [
    Cosigner('Peer 1', CosignerType.peer),
    Cosigner('Peer 2', CosignerType.peer),
    Cosigner('Card 2', CosignerType.card),
  ];
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary),
            child: const Text('Create'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
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
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.contactless_outlined),
                        title: const Text('Add NFC card'),
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
                        onTap: () {},
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
