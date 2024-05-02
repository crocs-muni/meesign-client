import 'dart:math';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_model.dart';

import 'dart:io';

import '../routes.dart';
import '../util/chars.dart';
import '../widget/device_name.dart';
import '../widget/weighted_avatar.dart';

class OptionTile extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  final EdgeInsets titlePadding;
  final List<Widget> children;
  final Widget? help;

  const OptionTile({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.titlePadding = const EdgeInsets.all(0),
    this.children = const [],
    this.help,
  });

  @override
  Widget build(BuildContext context) {
    Widget? helpButton;
    if (help != null) {
      helpButton = SizedBox.square(
        dimension: 24,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 20,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: const Icon(Symbols.help),
                  title: Text(title),
                  content: SingleChildScrollView(
                    child: help,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Symbols.help, opticalSize: 20),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: titlePadding,
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                if (helpButton != null) helpButton,
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class NumberInput extends StatelessWidget {
  final int value;
  final void Function(int)? onUpdate;

  const NumberInput({
    required this.value,
    this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Symbols.chevron_left),
          onPressed: onUpdate != null ? () => onUpdate!(value - 1) : null,
        ),
        Container(
          alignment: Alignment.center,
          width: 20,
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Symbols.chevron_right),
          onPressed: onUpdate != null ? () => onUpdate!(value + 1) : null,
        ),
      ],
    );
  }
}

class WarningBanner extends StatelessWidget {
  final String title;
  final String text;

  const WarningBanner({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.errorContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.warning,
                fill: 1,
                color: colorScheme.error,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

const int _minThreshold = 2;

class _NewGroupPageState extends State<NewGroupPage> {
  // TODO: store this in a Group object?
  int _threshold = _minThreshold;
  final List<Member> _members = [];
  final _nameController = TextEditingController();
  final _policyController = TextEditingController();
  String? _nameErr, _memberErr, _policyErr;
  KeyType _keyType = KeyType.signPdf;
  Protocol _protocol = KeyType.signPdf.supportedProtocols.first;
  bool _policyTime = false;
  TimeOfDay _policyAfterTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _policyBeforeTime = const TimeOfDay(hour: 23, minute: 59);
  bool _policyDecline = false;

  int get _shareCount => _members.map((m) => m.shares).sum;

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
    _policyController.addListener(() {
      if (_policyErr != null) {
        setState(() {
          _policyErr = null;
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
      _threshold = max(_minThreshold, min(value, _shareCount));

  void _addMembers(Object? devices) {
    if (devices is! List<Device>) return;
    setState(() {
      for (final device in devices) {
        if (_members.any((member) => member.device.id == device.id)) continue;
        _members.add(Member(device, 1));
      }
      if (_members.length >= 2) _memberErr = null;
    });
  }

  bool get _hasBot =>
      _members.any((member) => member.device.kind == DeviceKind.bot);

  void _selectPeer(String route) async {
    // TODO: pass the current selection to the search page?
    final devices = await Navigator.pushNamed(context, route);
    _addMembers(devices);
  }

  Map<String, dynamic> _buildPolicy({bool includeAll = false}) {
    String pad(num n) => n.toString().padLeft(2, '0');
    return {
      if (_policyTime || includeAll) ...{
        'after':
            '${pad(_policyAfterTime.hour)}:${pad(_policyAfterTime.minute)}',
        'before':
            '${pad(_policyBeforeTime.hour)}:${pad(_policyBeforeTime.minute)}',
      },
      if (_policyDecline || includeAll) 'decline': _policyDecline,
    };
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

    Map<String, dynamic> policy = _buildPolicy();

    if (_policyController.text.trim().isNotEmpty) {
      try {
        final customPolicy = jsonDecode(_policyController.text);
        policy = {...policy, ...customPolicy};
      } catch (e) {
        setState(() {
          _policyErr = 'Invalid JSON';
        });
      }
    }
    if (_nameErr != null || _memberErr != null || _policyErr != null) return;

    Navigator.pop(
      context,
      Group(
        const [],
        _nameController.text,
        _members,
        _threshold,
        _protocol,
        _keyType,
        note: _hasBot ? jsonEncode(policy) : null,
      ),
    );
  }

  // TODO: offer fix application?
  ({String title, String text})? _getWarning() {
    final gcd = _members.fold(_threshold, (gcd, m) => gcd.gcd(m.shares));
    // fix must satisfy fix * _threshold ~/ gcd >= _minThreshold
    final fix = (_minThreshold * gcd / _threshold).ceil();
    if (_members.length > 1 && fix < gcd) {
      final newThreshold = fix * _threshold ~/ gcd;
      final newShares = _members.map((m) => fix * m.shares ~/ gcd).join(', ');
      return (
        title: 'Unnecessarily many shares',
        text: 'You can achieve the same voting rights distribution by setting '
            'threshold to $newThreshold and shares to ($newShares). '
            'This may improve performance.',
      );
    }

    if (_shareCount > 20 && _protocol == Protocol.gg18) {
      return (
        title: 'Many shares',
        text: 'You may experience degraded performance with certain protocols '
            'if the share count is too high. Consider removing some members or '
            'lowering the number of shares they receive if this poses an issue.',
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final membersButtonStyle = _memberErr != null
        ? FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer)
        : null;

    final warning = _getWarning();

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
            help: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'By default, each member receives one share of the group\'s '
                  'private key. As a result, all members have equal voting '
                  'rights.\n\n'
                  'You can change the number of key shares a given member '
                  'receives using the arrows next to its name. The circle '
                  'around user\'s avatar visualizes its voting power.\n\n'
                  'For example, the user below receives one share which '
                  'amounts to one third of the total number of votes.',
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WeightedAvatar(
                      index: 0,
                      weights: [1, 2],
                      child: Text('E'),
                    ),
                    SizedBox(width: 16),
                    Text('example'),
                    SizedBox(width: 8),
                    NumberInput(
                      value: 1,
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Symbols.search),
                      label: const Text('Search'),
                      style: membersButtonStyle,
                      onPressed: () => _selectPeer(Routes.newGroupSearch),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (Platform.isAndroid || Platform.isIOS)
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Symbols.qr_code),
                        label: const Text('Scan'),
                        style: membersButtonStyle,
                        onPressed: () => _selectPeer(Routes.newGroupQr),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              for (final (i, member) in _members.indexed)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: WeightedAvatar(
                    index: i,
                    weights: _members.map((m) => m.shares).toList(),
                    child: Text(member.device.name.initials),
                  ),
                  title: DeviceName(
                    member.device.name,
                    kind: member.device.kind,
                    iconSize: 20,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NumberInput(
                        value: member.shares,
                        onUpdate: (newWeight) {
                          setState(() {
                            if (newWeight > 0) {
                              _members[i] = Member(member.device, newWeight);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _members.removeAt(i);
                          });
                        },
                        icon: const Icon(Symbols.delete),
                      )
                    ],
                  ),
                ),
            ],
          ),
          OptionTile(
            title: 'Threshold',
            help: const Text(
              'No group task can succeed unless at least the specified number '
              'of positive votes is gathered from the group\'s members.\n\n'
              'By carefully setting up the threshold and the number of shares '
              'each user receives, you can enforce that only certain subsets '
              'of the group can proceed with a given task.',
            ),
            children: [
              Row(
                children: [
                  const Icon(Symbols.person),
                  Expanded(
                    child: Slider(
                      value: min(_threshold, _shareCount).toDouble(),
                      min: 0,
                      max: _shareCount.toDouble(),
                      divisions: max(1, _shareCount),
                      label: '$_threshold',
                      onChanged: _shareCount > _minThreshold
                          ? (value) => setState(() {
                                _setThreshold(value.round());
                              })
                          : null,
                    ),
                  ),
                  const Icon(Symbols.people),
                ],
              ),
            ],
          ),
          if (warning != null)
            WarningBanner(
              title: warning.title,
              text: warning.text,
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
          if (_hasBot)
            OptionTile(
              padding: const EdgeInsets.symmetric(vertical: 12),
              titlePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: 'Policy',
              help: const Text(
                'If a bot is present in the group, you can set a policy that '
                'modifies its behavior (when to approve or decline requests).\n\n'
                'Depending on the bot\'s configuration, it may disregard the '
                'user-provided policy.',
              ),
              children: [
                CheckboxListTile(
                  value: _policyTime,
                  onChanged: (bool? value) {
                    setState(() {
                      _policyTime = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Row(
                    children: [
                      const Text('Time'),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: _policyTime
                            ? () async {
                                final value = await showTimePicker(
                                  context: context,
                                  initialTime: _policyAfterTime,
                                );
                                if (value != null) {
                                  setState(() {
                                    _policyAfterTime = value;
                                  });
                                }
                              }
                            : null,
                        icon: const Icon(Symbols.access_time),
                        label: Text(_policyAfterTime.format(context)),
                      ),
                      const Text(' – '),
                      FilledButton.tonalIcon(
                        onPressed: _policyTime
                            ? () async {
                                final value = await showTimePicker(
                                  context: context,
                                  initialTime: _policyBeforeTime,
                                );
                                if (value != null) {
                                  setState(() {
                                    _policyBeforeTime = value;
                                  });
                                }
                              }
                            : null,
                        icon: const Icon(Symbols.access_time),
                        label: Text(_policyBeforeTime.format(context)),
                      ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  value: _policyDecline,
                  onChanged: (bool? value) {
                    setState(() {
                      _policyDecline = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Decline if not satisfied immediately'),
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
              ),
              if (_hasBot)
                OptionTile(
                  title: 'Custom policy',
                  children: [
                    TextField(
                      controller: _policyController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        errorText: _policyErr,
                        hintText: const JsonEncoder.withIndent('  ')
                            .convert(_buildPolicy(includeAll: true)),
                      ),
                      maxLines: null,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
