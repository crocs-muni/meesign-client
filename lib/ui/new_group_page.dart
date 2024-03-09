import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_model.dart';

import 'dart:io';

import '../routes.dart';
import '../util/chars.dart';
import '../widget/entity_chip.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  final List<Widget> children;

  const OptionTile({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
            ] +
            children,
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
  Protocol _protocol = KeyType.signPdf.supportedProtocols.first;

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
      yield DeviceChip(
        device: member,
        onDeleted: () {
          setState(() {
            _members.remove(member);
            _setThreshold(_threshold);
          });
        },
      );
    }
  }

  void _addMembers(Object? devices) {
    if (devices is! List<Device>) return;
    setState(() {
      for (final device in devices) {
        if (_members.any((member) => member.id == device.id)) continue;
        _members.add(device);
      }
      if (_members.length >= 2) _memberErr = null;
    });
  }

  void _selectPeer(String route) async {
    // TODO: pass the current selection to the search page?
    final devices = await Navigator.pushNamed(context, route);
    _addMembers(devices);
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
        _protocol,
        _keyType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersButtonStyle = _memberErr != null
        ? FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _tryCreate,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          OptionTile(
            title: 'Name',
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  // labelText: 'Name',
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
            ],
          ),
          OptionTile(
            title: 'Members',
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                      style: membersButtonStyle,
                      onPressed: () => _selectPeer(Routes.newGroupSearch),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (Platform.isAndroid || Platform.isIOS)
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Scan'),
                        style: membersButtonStyle,
                        onPressed: () => _selectPeer(Routes.newGroupQr),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _memberChips.toList(),
              ),
            ],
          ),
          OptionTile(
            title: 'Threshold',
            children: [
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
          OptionTile(
            title: 'Purpose',
            children: [
              SegmentedButton<KeyType>(
                selected: {_keyType},
                onSelectionChanged: (value) {
                  setState(() {
                    _protocol = value.first.supportedProtocols.first;
                    _keyType = value.first;
                  });
                },
                segments: const [
                  ButtonSegment<KeyType>(
                    value: KeyType.signPdf,
                    label: Text('Sign PDF'),
                  ),
                  ButtonSegment<KeyType>(
                    value: KeyType.signChallenge,
                    label: Text('Challenge'),
                  ),
                  ButtonSegment<KeyType>(
                    value: KeyType.decrypt,
                    label: Text('Decrypt'),
                  )
                ],
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Advanced options'),
            collapsedTextColor:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OptionTile(
                title: 'Protocol',
                children: [
                  SegmentedButton<Protocol>(
                    selected: {_protocol},
                    onSelectionChanged: (value) {
                      setState(() => _protocol = value.first);
                    },
                    segments: [
                      for (var protocol in _keyType.supportedProtocols)
                        ButtonSegment<Protocol>(
                          value: protocol,
                          label: Text(protocol.name.toUpperCase()),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
