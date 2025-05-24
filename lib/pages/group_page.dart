import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_model.dart';

import '../util/chars.dart';
import '../widget/avatar_app_bar.dart';
import '../widget/device_name.dart';
import '../widget/weighted_avatar.dart';
import 'device_page.dart';

class GroupPage extends StatelessWidget {
  final Group group;

  const GroupPage({super.key, required this.group});

  static const kIconSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final weights = group.members.map((m) => m.shares).toList();
    bool isUser(Member m) => m.device.kind == DeviceKind.user;
    final nUsers = group.members.where(isUser).length;
    final nBots = group.members.length - nUsers;
    var policy = group.note;
    if (policy != null) {
      try {
        policy = jsonDecode(policy).toString();
      } on Exception {
        // show raw policy
      }
    }

    final children = [
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.group),
        ),
        title: const Text('Members'),
        subtitle: Text(
          '$nUsers user${nUsers == 1 ? '' : 's'}, '
          '$nBots bot${nBots == 1 ? '' : 's'}',
        ),
      ),
      for (final (i, member) in group.members.indexed)
        ListTile(
          leading: WeightedAvatar(
            index: i,
            weights: weights,
            child: Text(member.device.name.initials),
          ),
          title: DeviceName(
            member.device.name,
            kind: member.device.kind,
            iconSize: 20,
          ),
          trailing: Text(
            '(${member.shares})',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => DevicePage(
                  device: member.device,
                  showActionButtons: false,
                ),
              ),
            );
          },
        ),
      const SizedBox(height: 24),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.donut_large),
        ),
        title: const Text('Threshold'),
        subtitle: Text('${group.threshold} / ${group.shares}'),
      ),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.flag),
        ),
        title: const Text('Purpose'),
        subtitle: Text(switch (group.keyType) {
          KeyType.signPdf => 'Sign PDF',
          KeyType.signChallenge => 'Challenge',
          KeyType.decrypt => 'Decrypt',
        }),
      ),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.code),
        ),
        title: const Text('Protocol'),
        subtitle: Text(group.protocol.name.toUpperCase()),
      ),
      if (policy != null)
        ListTile(
          leading: const SizedBox.square(
            dimension: kIconSize,
            child: Icon(Symbols.policy),
          ),
          title: const Text('Policy'),
          subtitle: Text(policy),
        ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 192,
            pinned: true,
            flexibleSpace: FlexibleAvatarAppBar(
              avatar: Text(group.name.initials),
              title: Text(group.name),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Column(
                  children: children,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
