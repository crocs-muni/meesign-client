import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/device_page.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/actions/group_creator.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/widget/avatar_app_bar.dart';
import 'package:meesign_client/widget/device_name.dart';
import 'package:meesign_client/widget/weighted_avatar.dart';
import 'package:meesign_core/meesign_model.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({required this.group, super.key});
  final Group group;

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
        title: Text(AppLocalizations.of(context).members),
        subtitle: Text(
          AppLocalizations.of(context).membersSubtitle(
            nUsers,
            nUsers == 1 ? '' : 's',
            nBots,
            nBots == 1 ? '' : 's',
          ),
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
        title: Text(AppLocalizations.of(context).threshold),
        subtitle: Text('${group.threshold} / ${group.shares}'),
      ),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.flag),
        ),
        title: Text(AppLocalizations.of(context).purpose),
        subtitle: Text(
          switch (group.keyType) {
            KeyType.signPdf => AppLocalizations.of(context).signPdf,
            KeyType.signChallenge => AppLocalizations.of(context).challenge,
            KeyType.decrypt => AppLocalizations.of(context).decrypt,
          },
        ),
      ),
      ListTile(
        leading: const SizedBox.square(
          dimension: kIconSize,
          child: Icon(Symbols.code),
        ),
        title: Text(AppLocalizations.of(context).protocol),
        subtitle: Text(group.protocol.name.toUpperCase()),
      ),
      if (policy != null)
        ListTile(
          leading: const SizedBox.square(
            dimension: kIconSize,
            child: Icon(Symbols.policy),
          ),
          title: Text(AppLocalizations.of(context).policy),
          subtitle: Text(policy),
        ),
      const SizedBox(height: 24),
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: LARGE_PADDING),
          child: FilledButton.icon(
            onPressed: () async {
              final shouldRedirect =
                  await createGroup(context, context, groupTemplate: group);

              if (context.mounted && shouldRedirect) {
                Navigator.pop(context);
              }
            },
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(AppLocalizations.of(context).useTemplateForGroup),
            ),
            icon: const Icon(
              Icons.copy,
            ),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
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
          ),
        ],
      ),
    );
  }
}
