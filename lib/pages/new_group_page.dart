import 'dart:math';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

import 'dart:io';

import '../app_container.dart';
import '../routes.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../widget/device_name.dart';
import '../widget/number_input.dart';
import '../widget/option_tile.dart';
import '../widget/warning_banner.dart';
import '../widget/weighted_avatar.dart';

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
  String? _nameErr, _policyErr;
  ({String title, String text})? _sharesErr;
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

    final session = context.read<AppContainer>().session!;
    session.deviceRepository
        .getDevice(session.user.did)
        .then((device) => setState(() => _members.add(Member(device, 1))));
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
      _sharesErr = null;
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
    if (_shareCount < 2) {
      setState(() {
        _sharesErr = (
          title: 'At least two shares required',
          text: 'Either add new members to the group or '
              'give more shares to the existing members.',
        );
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
    if (_nameErr != null || _sharesErr != null || _policyErr != null) return;

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
  ({String title, String text})? _getSharesWarning() {
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

  Widget _buildCreateGroupButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: LARGE_GAP),
      child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _tryCreate,
          label: const Text('Create'),
          icon: Icon(Icons.create_new_folder)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharesIssue = _sharesErr ?? _getSharesWarning();

    return DefaultPageTemplate(
        showAppBar: true,
        appBarTitle: 'New group',
        body: _buildPageBody(sharesIssue));
  }

  Widget _buildPageBody(({String title, String text})? sharesIssue) {
    return Column(
      children: [
        Expanded(
          child: ListView(
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
                          onPressed: () => _selectPeer(Routes.newGroupSearch),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (Platform.isAndroid || Platform.isIOS)
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Symbols.qr_code),
                            label: const Text('Scan'),
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
                                  _members[i] =
                                      Member(member.device, newWeight);
                                  _sharesErr = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _members.removeAt(i);
                                _sharesErr = null;
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
              if (sharesIssue != null)
                WarningBanner(
                  title: sharesIssue.title,
                  text: sharesIssue.text,
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
                collapsedTextColor: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withValues(alpha: 0.5),
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
        ),
        _buildCreateGroupButton()
      ],
    );
  }
}
