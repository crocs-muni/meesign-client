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
import '../enums/task_type.dart';
import '../routes.dart';
import '../sessions/user_session.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../util/get_shares_warning.dart';
import '../widget/device_name.dart';
import '../widget/number_input.dart';
import '../widget/option_tile.dart';
import '../widget/warning_banner.dart';
import '../widget/weighted_avatar.dart';
import 'search_peer_page.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key, this.initialGroupType});

  final TaskType? initialGroupType;

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

const int _minThreshold = 2;

class _NewGroupPageState extends State<NewGroupPage> {
  // TODO: store this in a Group object?
  int _threshold = _minThreshold;
  final List<Member> _members = [];
  final List<Device> _devices = [];
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

    setInitialDevices(session);

    // Set initial purpose
    setState(() {
      if (widget.initialGroupType == TaskType.decrypt) {
        _keyType = KeyType.decrypt;
        _protocol = KeyType.decrypt.supportedProtocols.first;
      } else if (widget.initialGroupType == TaskType.sign) {
        _keyType = KeyType.signPdf;
        _protocol = KeyType.signPdf.supportedProtocols.first;
      } else if (widget.initialGroupType == TaskType.challenge) {
        _keyType = KeyType.signChallenge;
        _protocol = KeyType.signChallenge.supportedProtocols.first;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // This serves to auto-select current device on search-peers page
  Future<void> setInitialDevices(UserSession session) async {
    _devices.add(await session.deviceRepository.getDevice(session.user.did));
  }

  void _setThreshold(int value) {
    if (_protocol.thresholdType == ThresholdType.nOfN) {
      _threshold = _shareCount;
    } else {
      _threshold = max(_minThreshold, min(value, _shareCount));
    }
  }

  void _addMembers(Object? devices) {
    if (devices is! List<Device>) return;
    setState(() {
      for (final device in devices) {
        if (_members.any((member) => member.device.id == device.id)) continue;
        _members.add(Member(device, 1));
      }
      _sharesErr = null;
      if (_protocol.thresholdType == ThresholdType.nOfN) {
        _threshold = _shareCount;
      }
    });
  }

  bool get _hasBot =>
      _members.any((member) => member.device.kind == DeviceKind.bot);

  void _selectPeer(String route) async {
    final session = context.read<AppContainer>().session!;
    final navigator = Navigator.of(context, rootNavigator: false);
    Device device = await session.deviceRepository.getDevice(session.user.did);

    final devicesSelection = await navigator.push(
      MaterialPageRoute(
          builder: (context) => SearchPeerPage(
                initialSelection: _devices,
                currentDevice: device,
              )),
    );

    if (devicesSelection == null) {
      return;
    }

    for (final device in devicesSelection) {
      if (_devices.any((d) => d.id == device.id)) continue;
      _devices.add(device);
    }

    _addMembers(_devices);
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

    // Pass the new created group back to the previous screen where its handled
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

  Widget _buildCreateGroupButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: LARGE_GAP),
      child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _tryCreate,
          label: const Text('Create'),
          icon: Icon(Icons.send_rounded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharesIssue = _sharesErr ??
        getSharesWarning(
          members: _members,
          shareCount: _shareCount,
          threshold: _threshold,
          minThreshold: _minThreshold,
          protocol: _protocol,
        );

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
              _buildNameInput(),
              _buildMembersSection(),
              _buildTresholdSection(),
              if (sharesIssue != null)
                WarningBanner(
                  title: sharesIssue.title,
                  text: sharesIssue.text,
                ),
              _buildPurposeSection(),
              if (_hasBot) _buildBotSection(),
              _buildAdvancedSection(),
            ],
          ),
        ),
        _buildCreateGroupButton()
      ],
    );
  }

  Widget _buildNameInput() {
    int maxNameLength = 32;

    return OptionTile(
      title: 'Group Name',
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            // labelText: 'Name',
            border: const OutlineInputBorder(),
            errorText: _nameErr,
          ),
          maxLength: maxNameLength,
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp('[${RegExp.escape(asciiPunctuationChars)}]'),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return OptionTile(
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
                        _members[i] = Member(member.device, newWeight);
                        _sharesErr = null;
                        if (_protocol.thresholdType == ThresholdType.nOfN) {
                          _threshold = _shareCount;
                        }
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      // 1. Remove the selected device
                      _devices.removeWhere((d) => d.id == member.device.id);

                      // 2. Remove the member from the group
                      _members.removeAt(i);

                      _sharesErr = null;
                      if (_protocol.thresholdType == ThresholdType.nOfN) {
                        _threshold = _shareCount;
                      }
                      // Adjust threshold if it's now too high
                      if (_threshold > _shareCount) {
                        _setThreshold(_shareCount);
                      }
                    });
                  },
                  icon: const Icon(Symbols.delete),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTresholdSection() {
    return OptionTile(
      title: 'Threshold',
      help: const Text(
        'No group task can succeed unless at least the specified number '
        'of positive votes is gathered from the group\'s members.\n\n'
        'By carefully setting up the threshold and the number of shares '
        'each user receives, you can enforce that only certain subsets '
        'of the group can proceed with a given task.',
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.person),
                Expanded(
                  child: Slider(
                    value: (_protocol.thresholdType == ThresholdType.nOfN
                            ? _shareCount
                            : min(_threshold, _shareCount))
                        .toDouble(),
                    min: 0,
                    max: _shareCount.toDouble(),
                    divisions: max(1, _shareCount),
                    label: '$_threshold',
                    onChanged: (_protocol.thresholdType == ThresholdType.nOfN ||
                            _shareCount <= _minThreshold)
                        ? null
                        : (value) => setState(() {
                              _setThreshold(value.round());
                            }),
                  ),
                ),
                const Icon(Symbols.people),
              ],
            ),
            if (_protocol.thresholdType == ThresholdType.nOfN)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Important:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: SMALL_GAP),
                  Text(
                      "When using MUSIG2 protocol the threshold is always set to max number of shares. Therefore, it is not possible to use the slider.",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ],
              )
          ],
        )
      ],
    );
  }

  Widget _buildPurposeSection() {
    return OptionTile(
      title: 'Purpose',
      children: [
        SegmentedButton<KeyType>(
          selected: {_keyType},
          onSelectionChanged: (value) {
            setState(() {
              _protocol = value.first.supportedProtocols.first;
              _keyType = value.first;
              if (_protocol.thresholdType == ThresholdType.nOfN) {
                _threshold = _shareCount;
              }
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
    );
  }

  Widget _buildBotSection() {
    return OptionTile(
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
    );
  }

  Widget _buildAdvancedSection() {
    return ExpansionTile(
      title: const Text('Advanced options'),
      collapsedTextColor:
          Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OptionTile(
          title: 'Protocol',
          children: [
            SegmentedButton<Protocol>(
              selected: {_protocol},
              onSelectionChanged: (value) {
                setState(() {
                  _protocol = value.first;
                  if (_protocol.thresholdType == ThresholdType.nOfN) {
                    _threshold = _shareCount;
                  }
                });
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
    );
  }
}
