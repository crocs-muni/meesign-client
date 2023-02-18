import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_model.dart';

import 'dart:io';

import '../card/card.dart';
import '../routes.dart';
import '../util/chars.dart';

class SheetActionButton extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Function() onPressed;
  final bool enabled;

  const SheetActionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          IconButton(
            onPressed: enabled ? onPressed : null,
            icon: icon,
          ),
          title,
        ],
      ),
    );
  }
}

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
  KeyType _keyType = KeyType.signPdf;

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
      yield InputChip(
        label: Text(member.name),
        avatar: CircleAvatar(
          child: Text(
            member.name.initials,
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
      Group(
        const [],
        _nameController.text,
        _members,
        _threshold,
        Protocol.gg18,
        _keyType,
        Uint8List(0),
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
            tooltip: 'Create',
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
              labelText: 'Name',
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
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                // TODO: https://github.com/flutter/flutter/issues/118619
                constraints: const BoxConstraints(maxWidth: 640),
                builder: (context) {
                  return SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SheetActionButton(
                          icon: const Icon(Icons.qr_code),
                          title: const Text('Scan'),
                          enabled: Platform.isAndroid || Platform.isIOS,
                          onPressed: () => _selectPeer(Routes.newGroupQr),
                        ),
                        SheetActionButton(
                          icon: const Icon(Icons.contactless_outlined),
                          title: const Text('Card'),
                          enabled: false,
                          onPressed: () => _selectPeer(Routes.newGroupCard),
                        ),
                        SheetActionButton(
                          icon: const Icon(Icons.search),
                          title: const Text('Search'),
                          onPressed: () => _selectPeer(Routes.newGroupSearch),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            label: const Text('Add Member'),
            icon: const Icon(Icons.add),
            style: _memberErr != null
                ? FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer)
                : null,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _memberChips.toList(),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Purpose'),
          ),
          SegmentedButton<KeyType>(
            selected: {_keyType},
            onSelectionChanged: (value) {
              setState(() => _keyType = value.first);
            },
            segments: const [
              ButtonSegment<KeyType>(
                value: KeyType.signPdf,
                label: Text('Sign PDF'),
              ),
              ButtonSegment<KeyType>(
                value: KeyType.signDigest,
                label: Text('Log In'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
