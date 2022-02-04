import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  final AlignmentGeometry alignment;
  final Color? color;
  final IconData? icon;

  const DismissibleBackground({
    Key? key,
    required this.alignment,
    this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Align(
        alignment: alignment,
        child: AspectRatio(
          aspectRatio: 1,
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
  final String confirmTitle;
  final String? confirmDescription;
  final void Function(DismissDirection)? onDeleted;

  const Deletable({
    Key? key,
    required this.dismissibleKey,
    required this.child,
    this.confirmTitle = "Do you really want to delete this item?",
    this.confirmDescription,
    this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissibleKey,
      child: child,
      background: DismissibleBackground(
        alignment: Alignment.centerLeft,
        color: Theme.of(context).errorColor,
        icon: Icons.delete,
      ),
      secondaryBackground: DismissibleBackground(
        alignment: Alignment.centerRight,
        color: Theme.of(context).errorColor,
        icon: Icons.delete,
      ),
      confirmDismiss: (_) => showConfirmationDialog(
        context: context,
        title: confirmTitle,
        description: confirmDescription,
      ),
      onDismissed: onDeleted,
    );
  }
}
