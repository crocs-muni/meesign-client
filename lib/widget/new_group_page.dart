import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
import 'package:mpc_demo/util/rnd_name_generator.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import '../routes.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({Key? key}) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  // TODO: store this in a Group object?
  int _threshold = 1;
  final List<Cosigner> _members = [];
  final _nameController = TextEditingController();
  bool _creatable = false;

  @override
  void initState() {
    super.initState();
    _members.add(context.read<MpcModel>().thisDevice);
    _nameController.addListener(_checkCreatable);
    _nameController.text = RndNameGenerator().next();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Iterable<Widget> get _memberChips sync* {
    // always present, non-deleteable
    yield InputChip(
      label: Text(_members[0].name + ' (You)'),
      avatar: const CircleAvatar(
        child: Icon(Icons.person),
      ),
    );

    for (final Cosigner member in _members.skip(1)) {
      final icon =
          member.type == CosignerType.app ? Icons.person : Icons.contactless;
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

  void _addMember(Object? member) {
    if (member is! Cosigner) return;
    for (final m in _members) {
      if (listEquals(m.id, member.id)) return;
    }
    setState(() {
      _members.add(member);
      _checkCreatable();
    });
  }

  void _selectSearchedPeer() async {
    final peer = await Navigator.pushNamed(context, Routes.newGroupSearch);
    _addMember(peer);
  }

  void _selectCard() async {
    final card = await Navigator.pushNamed(context, Routes.newGroupCard);
    _addMember(card);
  }

  void _selectQr() async {
    final peer = await Navigator.pushNamed(context, Routes.newGroupQr);
    _addMember(peer);
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
                elevation: 4,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                context: context,
                builder: (context) {
                  return Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.qr_code),
                        title: const Text('Scan QR code'),
                        enabled: Platform.isAndroid || Platform.isIOS,
                        onTap: _selectQr,
                      ),
                      ListTile(
                        leading: const Icon(Icons.contactless_outlined),
                        title: const Text('Add NFC card'),
                        enabled: Platform.isAndroid || Platform.isIOS,
                        onTap: _selectCard,
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
