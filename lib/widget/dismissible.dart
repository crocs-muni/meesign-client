import 'package:flutter/material.dart';

import 'package:meesign_client/l10n/arb/app_localizations.dart';

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({
    required this.alignment,
    super.key,
    this.color,
    this.icon,
  });
  final AlignmentGeometry alignment;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon),
        ),
      ),
    );
  }
}

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  String? description,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: description != null ? Text(description) : null,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      );
    },
  );
}

class Deletable extends StatefulWidget {
  Deletable({
    required this.dismissibleKey,
    required Widget child,
    super.key,
    this.color = Colors.red,
    this.icon = Icons.delete,
    this.confirmDismiss,
    this.onDeleted,
  }) : childBuilder = ((isDragging) => child);

  const Deletable.builder({
    required this.dismissibleKey,
    required this.childBuilder,
    super.key,
    this.color = Colors.red,
    this.icon = Icons.delete,
    this.confirmDismiss,
    this.onDeleted,
  });
  final Key dismissibleKey;
  // Builder pattern requires positional bool for drag state.
  // ignore: avoid_positional_boolean_parameters
  final Widget Function(bool isDragging) childBuilder;
  final Color color;
  final IconData icon;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDeleted;

  @override
  State<Deletable> createState() => _DeletableState();
}

class _DeletableState extends State<Deletable> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.dismissibleKey,
      background: DismissibleBackground(
        alignment: Alignment.centerLeft,
        color: widget.color,
        icon: widget.icon,
      ),
      secondaryBackground: DismissibleBackground(
        alignment: Alignment.centerRight,
        color: widget.color,
        icon: widget.icon,
      ),
      confirmDismiss: widget.confirmDismiss ??
          (_) async {
            setState(() => _isDragging = false);
            return true;
          },
      onUpdate: (details) {
        final newIsDragging = details.progress > 0;
        if (newIsDragging != _isDragging) {
          setState(() => _isDragging = newIsDragging);
        }
      },
      onDismissed: widget.onDeleted,
      child: widget.childBuilder(_isDragging),
    );
  }
}
