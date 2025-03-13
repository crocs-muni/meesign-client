import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';

import '../enums/data_input_type.dart';
import '../util/chars.dart';

class DataInputDialog extends StatefulWidget {
  final String title;
  final Set<DataInputType> dataInputTypes;
  final DataInputType? defaultDataInputType;

  DataInputDialog({
    super.key,
    this.title = 'Enter input',
    required this.dataInputTypes,
    this.defaultDataInputType,
  }) {
    assert(dataInputTypes.isNotEmpty);
    if (defaultDataInputType != null) {
      assert(dataInputTypes.contains(defaultDataInputType));
    }
  }

  @override
  State<DataInputDialog> createState() => _DataInputDialogState();
}

class _DataInputDialogState extends State<DataInputDialog> {
  final _description = TextEditingController();
  late DataInputType _dataInputType;

  final _message = TextEditingController();

  Uint8List? _image;
  MimeType? _imageMimeType;

  Future<void> _selectImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    final header =
        bytes.sublist(0, min(defaultMagicNumbersMaxLength, bytes.length));
    final mimeTypeStr = lookupMimeType(file.path, headerBytes: header);

    setState(() {
      _image = bytes;
      _imageMimeType = mimeTypeStr != null ? MimeType(mimeTypeStr) : null;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    final (mimeType, data) = switch (_dataInputType) {
      DataInputType.text => (MimeType.textUtf8, utf8.encode(_message.text)),
      DataInputType.image => (_imageMimeType, _image),
    };
    final description = _description.text;

    // TODO: disable ok button instead
    if (description.isEmpty || mimeType == null || data == null) return;

    Navigator.pop(context, (description, mimeType, data));
  }

  @override
  void initState() {
    super.initState();
    _dataInputType = widget.defaultDataInputType ?? widget.dataInputTypes.first;
  }

  @override
  void didUpdateWidget(covariant DataInputDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dataInputType = widget.defaultDataInputType ?? widget.dataInputTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return AlertDialog(
      title: Text(widget.title),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleOk,
          child: const Text('OK'),
        )
      ],
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _description,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<DataInputType>(
            selected: {_dataInputType},
            showSelectedIcon: false,
            onSelectionChanged: (values) {
              setState(() {
                _dataInputType = values.first;
              });
            },
            segments: [
              for (final type in widget.dataInputTypes)
                ButtonSegment<DataInputType>(
                  value: type,
                  icon: Icon(
                    switch (type) {
                      DataInputType.text => Symbols.description,
                      DataInputType.image => Symbols.image,
                    },
                    fill: _dataInputType == type ? 1 : 0,
                  ),
                  label: Text(type.name.capitalize()),
                ),
            ],
          ),
          const SizedBox(height: 16),
          switch (_dataInputType) {
            DataInputType.text => TextField(
                controller: _message,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Message',
                ),
              ),
            DataInputType.image => image == null
                ? OutlinedButton(
                    onPressed: _selectImage,
                    child: const Text('Select'),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      _imageMimeType == MimeType.imageSvg
                          ? SvgPicture.memory(image)
                          : Image.memory(image),
                      Positioned.fill(
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            onTap: _selectImage,
                          ),
                        ),
                      ),
                    ],
                  ),
          },
        ],
      ),
    );
  }
}
