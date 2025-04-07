import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class NumberInput extends StatelessWidget {
  final int value;
  final void Function(int)? onUpdate;

  const NumberInput({
    required this.value,
    this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Symbols.chevron_left),
          onPressed: onUpdate != null ? () => onUpdate!(value - 1) : null,
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
          icon: const Icon(Symbols.chevron_right),
          onPressed: onUpdate != null ? () => onUpdate!(value + 1) : null,
        ),
      ],
    );
  }
}
