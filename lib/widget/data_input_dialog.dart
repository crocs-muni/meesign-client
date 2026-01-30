import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/enums/data_input_type.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';

class DataInputDialog extends StatefulWidget {
  DataInputDialog({
    required this.dataInputTypes,
    super.key,
    String? title,
    this.defaultDataInputType,
  })  : assert(
          dataInputTypes.isNotEmpty,
          'dataInputTypes must not be empty',
        ),
        assert(
          defaultDataInputType == null ||
              dataInputTypes.contains(defaultDataInputType),
          'defaultDataInputType must be in dataInputTypes',
        ),
        _title = title;
  final String? _title;
  final Set<DataInputType> dataInputTypes;
  final DataInputType? defaultDataInputType;

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

    // TODO(dev): disable ok button instead
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
      title: Text(widget._title ?? AppLocalizations.of(context).enterInput),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: _handleOk,
          child: Text(AppLocalizations.of(context).ok),
        ),
      ],
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _description,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: AppLocalizations.of(context).description,
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).message,
                ),
              ),
            DataInputType.image => image == null
                ? OutlinedButton(
                    onPressed: _selectImage,
                    child: Text(AppLocalizations.of(context).select),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imageMimeType == MimeType.imageSvg)
                        SvgPicture.memory(image)
                      else
                        Image.memory(image),
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
