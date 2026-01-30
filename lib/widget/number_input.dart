import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

class NumberInput extends StatefulWidget {
  const NumberInput({
    required this.value,
    this.onUpdate,
    super.key,
  });
  final int value;
  final void Function(int)? onUpdate;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  final _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _numberController.text = widget.value.toString();

    _numberController.addListener(
      () {
        if (_numberController.text.isEmpty) {
          _numberController.text = '1';
        } else {
          final newValue = int.tryParse(_numberController.text);
          if (newValue != null && widget.onUpdate != null) {
            widget.onUpdate!(newValue);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Symbols.chevron_left),
          onPressed: widget.onUpdate != null
              ? () {
                  final newValue = int.parse(_numberController.text) - 1;

                  if (newValue < 1) {
                    return;
                  }

                  _numberController.text = newValue.toString();
                  widget.onUpdate!(newValue);
                }
              : null,
        ),
        Container(
          alignment: Alignment.center,
          width: 25,
          child: TextField(
            controller: _numberController,
            maxLength: 7,
            onChanged: (text) {
              final newValue = int.tryParse(text);
              if (newValue != null && widget.onUpdate != null) {
                widget.onUpdate!(newValue);
              }
            },
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Symbols.chevron_right),
          onPressed: widget.onUpdate != null
              ? () {
                  final newValue = int.parse(_numberController.text) + 1;
                  _numberController.text = newValue.toString();
                  widget.onUpdate!(newValue);
                }
              : null,
        ),
      ],
    );
  }
}
