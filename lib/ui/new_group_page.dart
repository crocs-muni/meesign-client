import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_model.dart';

import 'dart:io';

import '../routes.dart';
import '../util/chars.dart';

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

class NumberInput extends StatelessWidget {
  final int value;
  final void Function(int) onUpdate;

  const NumberInput({
    required this.value,
    required this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onUpdate(value - 1),
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
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onUpdate(value + 1),
        ),
      ],
    );
  }
}

class WeightedAvatar extends StatelessWidget {
  final int index;
  final List<int> weights;
  final Widget? child;

  const WeightedAvatar({
    super.key,
    required this.index,
    required this.weights,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox.square(
          dimension: 32,
          child: CircleAvatar(
            child: child,
          ),
        ),
        SizedBox.square(
          dimension: 40,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              sections: [
                for (final (j, weight) in weights.indexed)
                  PieChartSectionData(
                    radius: 2,
                    value: weight.toDouble(),
                    showTitle: false,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(j == index ? 1 : .2),
                  )
              ],
            ),
          ),
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
                Icons.warning,
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
  String? _nameErr, _memberErr;
  KeyType _keyType = KeyType.signPdf;
  Protocol _protocol = KeyType.signPdf.supportedProtocols.first;

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
              for (final (i, member) in _members.indexed)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: WeightedAvatar(
                    index: i,
                    weights: _members.map((m) => m.shares).toList(),
                    child: Text(member.device.name.initials),
                  ),
                  title: Text(
                    member.device.name,
                    softWrap: false,
                    overflow: TextOverflow.fade,
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
                        icon: const Icon(Icons.delete),
                      )
                    ],
                  ),
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
                  const Icon(Icons.people),
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
