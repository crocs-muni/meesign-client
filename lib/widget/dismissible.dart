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

class Deletable extends StatefulWidget {
  final Key dismissibleKey;
  final Widget Function(bool isDragging) childBuilder;
  final Color color;
  final IconData icon;
  final Future<bool?> Function(DismissDirection)? confirmDismiss;
  final void Function(DismissDirection)? onDeleted;

  Deletable({
    super.key,
    required this.dismissibleKey,
    required Widget child,
    this.color = Colors.red,
    this.icon = Icons.delete,
    this.confirmDismiss,
    this.onDeleted,
  }) : childBuilder = ((isDragging) => child);

  const Deletable.builder({
    super.key,
    required this.dismissibleKey,
    required this.childBuilder,
    this.color = Colors.red,
    this.icon = Icons.delete,
    this.confirmDismiss,
    this.onDeleted,
  });

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
