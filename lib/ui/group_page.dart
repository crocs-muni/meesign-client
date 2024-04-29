import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';

import '../util/chars.dart';
import '../widget/avatar_app_bar.dart';
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

    final children = [
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Icons.group),
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
          title: Text(
            member.device.name,
            softWrap: false,
            overflow: TextOverflow.fade,
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
                ),
              ),
            );
          },
        ),
      const SizedBox(height: 24),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Icons.donut_large),
        ),
        title: const Text('Threshold'),
        subtitle: Text('${group.threshold} / ${group.shares}'),
      ),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Icons.flag),
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
          child: Icon(Icons.code),
        ),
        title: const Text('Protocol'),
        subtitle: Text(group.protocol.name.toUpperCase()),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 192,
            pinned: true,
            flexibleSpace: FlexibleAvatarAppBar(
              name: group.name,
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
