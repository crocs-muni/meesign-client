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
import '../l10n/arb/app_localizations.dart';
import '../routes.dart';
import '../sessions/user_session.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../util/get_shares_warning.dart';
import '../view_model/tabs_view_model.dart';
import '../widget/device_name.dart';
import '../widget/number_input.dart';
import '../widget/option_tile.dart';
import '../widget/warning_banner.dart';
import '../widget/weighted_avatar.dart';
import 'search_peer_page.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key, this.initialGroupType, this.templateGroup});

  final TaskType? initialGroupType;
  final Group? templateGroup;

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
  bool _membersErr = false;
  bool _nameErr = false;
  bool _policyErr = false;
  bool _sharesErr = false;
  KeyType _keyType = KeyType.signPdf;
  Protocol _protocol = KeyType.signPdf.supportedProtocols.first;
  bool _policyTime = false;
  TimeOfDay _policyAfterTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _policyBeforeTime = const TimeOfDay(hour: 23, minute: 59);
  bool _policyDecline = false;
  bool _isCreatingFromTemplate = false;

  int get _shareCount => _members.map((m) => m.shares).sum;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TabsViewModel>().setNewGroupPageInStack(true);
    });

    // Reset errors on input change
    _nameController.addListener(() {
      if (_nameErr) {
        setState(() {
          _nameErr = false;
        });
      }
    });

    _policyController.addListener(() {
      if (_policyErr) {
        setState(() {
          _policyErr = false;
        });
      }
    });

    final session = context.read<AppContainer>().session!;

    if (widget.templateGroup != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createGroupFromTemplate(session);
      });
    } else {
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
  }

  void _createGroupFromTemplate(UserSession session) {
    setState(() {
      if (widget.templateGroup != null) {
        final template = widget.templateGroup!;
        _isCreatingFromTemplate = true;
        _nameController.text =
            '${template.name} ${AppLocalizations.of(context).copyNoun}';
        _threshold = template.threshold;
        _keyType = template.keyType;
        _protocol = template.protocol;

        final templateDevices = template.members.map((m) => m.device).toList();
        _devices.addAll(templateDevices);
        _addMembers(templateDevices);

        // Update shares to match template values
        for (final templateMember in template.members) {
          final memberIndex = _members
              .indexWhere((m) => m.device.id == templateMember.device.id);
          if (memberIndex >= 0) {
            _members[memberIndex] =
                Member(_members[memberIndex].device, templateMember.shares);
          }
        }

        // Set policy from template if it exists
        if (template.note != null) {
          try {
            final policy = jsonDecode(template.note!);
            if (policy['after'] != null && policy['before'] != null) {
              _policyTime = true;
              final afterParts = policy['after'].split(':');
              final beforeParts = policy['before'].split(':');
              _policyAfterTime = TimeOfDay(
                  hour: int.parse(afterParts[0]),
                  minute: int.parse(afterParts[1]));
              _policyBeforeTime = TimeOfDay(
                  hour: int.parse(beforeParts[0]),
                  minute: int.parse(beforeParts[1]));
            }
            if (policy['decline'] != null) {
              _policyDecline = policy['decline'];
            }

            // Set custom policy text (excluding already handled fields)
            final customPolicy = Map<String, dynamic>.from(policy);
            customPolicy.remove('after');
            customPolicy.remove('before');
            customPolicy.remove('decline');
            if (customPolicy.isNotEmpty) {
              _policyController.text =
                  const JsonEncoder.withIndent('  ').convert(customPolicy);
            }
          } catch (e) {
            // If parsing fails, just ignore the policy
          }
        }

        // Restore template threshold and reset flag
        _threshold = template.threshold;
        _isCreatingFromTemplate = false;
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
      _sharesErr = false;
      _membersErr = false;
      if (_protocol.thresholdType == ThresholdType.nOfN &&
          !_isCreatingFromTemplate) {
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
        _nameErr = true;
      });
    }

    final sharesIssue = getSharesWarning(
      members: _members,
      shareCount: _shareCount,
      threshold: _threshold,
      minThreshold: _minThreshold,
      protocol: _protocol,
    );

    if (sharesIssue != null) {
      setState(() {
        _sharesErr = true;
      });
    }

    final AppContainer container = context.read<AppContainer>();
    final minGroupMembers =
        container.settingsController.currentSettings.minGroupMembers;

    if (_members.length < minGroupMembers) {
      setState(() {
        _membersErr = true;
      });
    } else {
      setState(() {
        _membersErr = false;
      });
    }

    Map<String, dynamic> policy = _buildPolicy();

    if (_policyController.text.trim().isNotEmpty) {
      try {
        final customPolicy = jsonDecode(_policyController.text);
        policy = {...policy, ...customPolicy};
      } catch (e) {
        setState(() {
          _policyErr = true;
        });
      }
    }

    if (_nameErr || _sharesErr || _policyErr || _membersErr) {
      return;
    }

    TabsViewModel model = context.read<TabsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      model.setNewGroupPageInStack(false);
    });

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
      margin: const EdgeInsets.symmetric(
          vertical: LARGE_GAP, horizontal: SMALL_GAP),
      child: FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _tryCreate,
          label: Text(AppLocalizations.of(context).create),
          icon: Icon(Icons.send_rounded)),
    );
  }

  @override
  Widget build(BuildContext context) {
    TabsViewModel model = context.read<TabsViewModel>();

    return DefaultPageTemplate(
        showAppBar: true,
        appBarTitle: AppLocalizations.of(context).newGroupTitle,
        includePadding: false,
        onBackButtonPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            model.setNewGroupPageInStack(false);
          });
        },
        body: _buildPageBody());
  }

  Widget _buildPageBody() {
    final AppContainer container = context.read<AppContainer>();
    final minGroupMembers =
        container.settingsController.currentSettings.minGroupMembers;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildNameInput(),
              _buildMembersSection(),
              if (_membersErr)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
                  child: WarningBanner(
                    title:
                        AppLocalizations.of(context).moreGroupMembersRequired,
                    text: AppLocalizations.of(context)
                        .minimumMembersRequired(minGroupMembers),
                  ),
                ),
              _buildThresholdSection(),
              if (_sharesErr) ...[_buildReactiveWarningBanner()],
              _buildPurposeSection(),
              if (_hasBot) _buildBotSection(),
              _buildAdvancedSection(),
              SizedBox(height: XLARGE_GAP),
              _buildCreateGroupButton()
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactiveWarningBanner() {
    final shareWarning = getSharesWarning(
      members: _members,
      shareCount: _shareCount,
      threshold: _threshold,
      minThreshold: _minThreshold,
      protocol: _protocol,
    );

    var title = '';
    var warningText = '';

    switch (shareWarning?.warningType) {
      case ShareWarningType.manyShares:
        title = AppLocalizations.of(context).manySharesWarning;
        warningText = AppLocalizations.of(context).manySharesWarningText;
        break;
      case ShareWarningType.unnecessaryShares:
        title = AppLocalizations.of(context).unnecessarySharesTitle;
        warningText = AppLocalizations.of(context).unnecessarySharesText(
            shareWarning?.warningParams?[0] ?? '',
            shareWarning?.warningParams?[1] ?? '');
        break;
      case ShareWarningType.atLeastTwoShares:
        title = AppLocalizations.of(context).atLeastTwoSharesRequired;
        warningText = AppLocalizations.of(context).atLeastTwoSharesRequiredText;
        break;
      case null:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
      child: WarningBanner(
        title: title,
        text: warningText,
      ),
    );
  }

  Widget _buildNameInput() {
    int maxNameLength = 32;

    return OptionTile(
      title: AppLocalizations.of(context).groupName,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText:
                _nameErr ? AppLocalizations.of(context).enterGroupName : null,
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
      title: AppLocalizations.of(context).members,
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
                label: Text(AppLocalizations.of(context).addMembers),
                onPressed: () => _selectPeer(Routes.newGroupSearch),
              ),
            ),
            const SizedBox(width: 8),
            if (Platform.isAndroid || Platform.isIOS)
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Symbols.qr_code),
                  label: Text(AppLocalizations.of(context).scan),
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
                        _sharesErr = false;
                        if (_protocol.thresholdType == ThresholdType.nOfN) {
                          _threshold = _shareCount;
                        }

                        if (_threshold > _shareCount) {
                          _setThreshold(_shareCount);
                        }
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                FutureBuilder<Widget>(
                  future: _buildDeleteIcon(member, i, context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!;
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<Widget> _buildDeleteIcon(
      Member member, int i, BuildContext context) async {
    final session = context.read<AppContainer>().session!;
    Device device = await session.deviceRepository.getDevice(session.user.did);

    return IconButton(
      onPressed: member.device.id == device.id
          ? null
          : () {
              setState(() {
                // 1. Remove the selected device
                _devices.removeWhere((d) => d.id == member.device.id);

                // 2. Remove the member from the group
                _members.removeAt(i);

                _sharesErr = false;
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
    );
  }

  Widget _buildThresholdSection() {
    return OptionTile(
      title: AppLocalizations.of(context).threshold,
      help: Text(
        AppLocalizations.of(context).thresholdHelpText,
      ),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.person),
                Expanded(
                  child: GestureDetector(
                    onTap: (_protocol.thresholdType == ThresholdType.nOfN)
                        ? () => displayWarningDialog()
                        : null,
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart:
                        (_protocol.thresholdType == ThresholdType.nOfN)
                            ? (_) => displayWarningDialog()
                            : null,
                    child: Slider(
                      value: (_protocol.thresholdType == ThresholdType.nOfN
                              ? _shareCount
                              : min(_threshold, _shareCount))
                          .toDouble(),
                      min: 0,
                      max: _shareCount.toDouble(),
                      divisions: max(1, _shareCount),
                      label: '$_threshold',
                      onChanged:
                          (_protocol.thresholdType == ThresholdType.nOfN ||
                                  _shareCount <= 2)
                              ? null
                              : (value) => setState(() {
                                    _setThreshold(value.round());
                                  }),
                    ),
                  ),
                ),
                const Icon(Symbols.people),
              ],
            ),
          ],
        )
      ],
    );
  }

  void displayWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).shareSliderDisabledTitle),
        content: Text(AppLocalizations.of(context).shareSliderDisabledText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSection() {
    return OptionTile(
      title: AppLocalizations.of(context).purpose,
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
      title: AppLocalizations.of(context).policy,
      help: Text(
        AppLocalizations.of(context).policyHelpText,
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
              Text(AppLocalizations.of(context).time),
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
              Text(' — '),
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
          title: Text(
              AppLocalizations.of(context).declineIfNotSatisfiedImmediately),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return ExpansionTile(
      title: Text(AppLocalizations.of(context).advancedOptions),
      collapsedTextColor:
          Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
      children: [
        OptionTile(
          title: AppLocalizations.of(context).protocol,
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
            title: AppLocalizations.of(context).customPolicy,
            children: [
              TextField(
                controller: _policyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: _policyErr
                      ? AppLocalizations.of(context).invalidJson
                      : null,
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
