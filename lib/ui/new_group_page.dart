import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_model.dart';

import 'dart:io';

import '../card/card.dart';
import '../routes.dart';
import '../util/chars.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({Key? key}) : super(key: key);

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

const int _minThreshold = 2;

class _NewGroupPageState extends State<NewGroupPage> {
  // TODO: store this in a Group object?
  int _threshold = _minThreshold;
  final List<Device> _members = [];
  final _nameController = TextEditingController();
  String? _nameErr, _memberErr;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (_nameErr != null) {
        setState(() {
          _nameErr = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setThreshold(int value) =>
      _threshold = max(_minThreshold, min(value, _members.length));

  Iterable<Widget> get _memberChips sync* {
    for (final Device member in _members) {
      final icon =
          member.type == DeviceType.app ? Icons.person : Icons.contactless;
      yield InputChip(
        label: Text(member.name),
        avatar: CircleAvatar(
          child: Icon(icon),
        ),
        onDeleted: () {
          setState(() {
            _members.remove(member);
            _setThreshold(_threshold);
          });
        },
      );
    }
  }

  void _addMember(Object? member) {
    if (member is! Device) return;
    for (final m in _members) {
      if (m.id == member.id) return;
    }
    setState(() {
      _members.add(member);
      _memberErr = null;
    });
  }

  void _selectPeer(String route) async {
    final peer = await Navigator.pushNamed(context, route);
    _addMember(peer);
  }

  void _tryCreate() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameErr = "Enter group name";
      });
    }
    if (_members.length < 2) {
      setState(() {
        _memberErr = "Add member";
      });
    }
    if (_nameErr != null || _memberErr != null) return;

    Navigator.pop(
      context,
      GroupBase(
        _nameController.text,
        _members,
        _threshold,
        Protocol.gg18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          IconButton(
            onPressed: _tryCreate,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Group name',
              border: const OutlineInputBorder(),
              errorText: _nameErr,
            ),
            maxLength: 32,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp('[${RegExp.escape(asciiPunctuationChars)}]'),
              )
            ],
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
                        onTap: () => _selectPeer(Routes.newGroupQr),
                      ),
                      ListTile(
                        leading: const Icon(Icons.contactless_outlined),
                        title: const Text('Add card'),
                        enabled: CardManager.platformSupported,
                        onTap: () => _selectPeer(Routes.newGroupCard),
                      ),
                      ListTile(
                        leading: const Icon(Icons.search),
                        title: const Text('Search peer'),
                        onTap: () => _selectPeer(Routes.newGroupSearch),
                      ),
                    ],
                  );
                },
              );
            },
            label: const Text('New member'),
            icon: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              primary: _memberErr != null ? Theme.of(context).errorColor : null,
            ),
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
          const Text(
            'Threshold',
          ),
          Row(
            children: [
              const Icon(Icons.person),
              Expanded(
                child: Slider(
                  value: min(_threshold, _members.length).toDouble(),
                  min: 0,
                  max: _members.length.toDouble(),
                  divisions: max(1, _members.length),
                  label: '$_threshold',
                  onChanged: _members.length > _minThreshold
                      ? (value) => setState(() {
                            _setThreshold(value.round());
                          })
                      : null,
                ),
              ),
              const Icon(Icons.people),
            ],
          ),
        ],
      ),
    );
  }
}
