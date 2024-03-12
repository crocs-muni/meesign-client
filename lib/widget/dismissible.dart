import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  final AlignmentGeometry alignment;
  final Color? color;
  final IconData? icon;

  const DismissibleBackground({
    super.key,
    required this.alignment,
    this.color,
    this.icon,
  });

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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

class Deletable extends StatelessWidget {
  final Key dismissibleKey;
  final Widget child;
  final Color color;
  final IconData icon;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDeleted;

  const Deletable({
    super.key,
    required this.dismissibleKey,
    required this.child,
    this.color = Colors.red,
    this.icon = Icons.delete,
    this.confirmDismiss,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissibleKey,
      background: DismissibleBackground(
        alignment: Alignment.centerLeft,
        color: color,
        icon: icon,
      ),
      secondaryBackground: DismissibleBackground(
        alignment: Alignment.centerRight,
        color: color,
        icon: icon,
      ),
      confirmDismiss: confirmDismiss,
      onDismissed: onDeleted,
      child: child,
    );
  }
}
