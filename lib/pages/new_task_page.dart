import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/pick_pdf_file.dart';
import '../view_model/app_view_model.dart';
import '../widget/error_dialog.dart';
import '../widget/group_suggestion_tile.dart';
import '../widget/option_tile.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage(
      {super.key, this.initialTaskType, this.showTaskTypeSelector = false});

  final KeyType? initialTaskType;
  final bool showTaskTypeSelector;
  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  KeyType _taskType = KeyType.signPdf;
  Group? _selectedGroup;
  Uint8List? _image;
  MimeType? _imageMimeType;
  XFile? _pdfFile;
  bool _showImageSelector = false;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _groupScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialTaskType != null) {
      _taskType = widget.initialTaskType!;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _messageController.dispose();
    _groupScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      showAppBar: true,
      appBarTitle: "Create new task",
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTaskTypeSelector) ...[
            _buildTaskTypeSelector(),
          ],
          _buildGroupSelector(context),
          Divider(
            height: 1,
            thickness: 0.5,
            indent: MEDIUM_PADDING,
          ),
          SizedBox(height: MEDIUM_GAP),
          _buildTaskBuilder(),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return OptionTile(
      title: 'Type of task',
      children: [
        SegmentedButton<KeyType>(
          selected: {_taskType},
          onSelectionChanged: (value) {
            setState(() {
              _taskType = value.first;
              _selectedGroup = null;
            });
          },
          segments: const [
            ButtonSegment<KeyType>(
              value: KeyType.signPdf,
              label: Text('Sign PDF'),
            ),
            ButtonSegment<KeyType>(
              value: KeyType.signChallenge,
              label: Text('Challenge'),
            ),
            ButtonSegment<KeyType>(
              value: KeyType.decrypt,
              label: Text('Decrypt'),
            )
          ],
        ),
      ],
    );
  }

  String _getTaskTypeDescription() {
    switch (_taskType) {
      case KeyType.signPdf:
        return 'PDF signing';
      case KeyType.signChallenge:
        return 'challenge';
      case KeyType.decrypt:
        return 'decryption';
    }
  }

  Widget _buildTaskBuilder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_taskType == KeyType.signPdf) ...[
            _buildPdfSelector(context),
          ] else ...[
            _buildTaskDesc(),
            SizedBox(height: LARGE_GAP),
            if (_taskType == KeyType.decrypt) ...[
              _buildContentTypeSelector(),
            ],
            if (_showImageSelector && _taskType == KeyType.decrypt)
              ..._buildImageSelector(context),
            if (!_showImageSelector || _taskType == KeyType.signChallenge)
              _buildTaskMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter description",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                filled: true,
                hintText:
                    'Enter description of the ${_getTaskTypeDescription()} task',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 0),
                ),
                errorText: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: false,
              groupValue: _showImageSelector,
              onChanged: (value) {
                setState(() {
                  _showImageSelector = value!;
                });
              },
            ),
            Flexible(child: const Text('Decrypt a message')),
            SizedBox(width: LARGE_GAP),
            Radio<bool>(
              value: true,
              groupValue: _showImageSelector,
              onChanged: (value) {
                setState(() {
                  _showImageSelector = value!;
                });
              },
            ),
            Flexible(child: const Text('Decrypt an image')),
          ],
        ),
        SizedBox(height: LARGE_GAP),
      ],
    );
  }

  List<Widget> _buildImageSelector(BuildContext context) {
    return [
      if (_image == null) ...[
        OutlinedButton(
          onPressed: () => _selectImage(context),
          child: const Text('Select image'),
        ),
      ],
      if (_image != null) ...[
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: _imageMimeType == MimeType.imageSvg
                      ? SvgPicture.memory(_image!)
                      : Image.memory(_image!),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _selectImage(context),
                ),
              ),
            ),
          ],
        ),
      ]
    ];
  }

  Widget _buildTaskMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter message",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _messageController,
              maxLines: 5,
              minLines: 3,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                filled: true,
                hintText: 'Enter the message',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 0),
                ),
                errorText: null,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildGroupSelector(BuildContext buildContext) {
    final state = buildContext.read<AppViewModel>();
    final groups = state.groupTasks
        .where((task) =>
            task.state == TaskState.finished &&
            task.info.keyType == _taskType &&
            !task.archived)
        .map((task) => task.info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: MEDIUM_PADDING, top: LARGE_PADDING),
          child: Text(
            'Select group for the new task',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        if (groups.isEmpty)
          Padding(
            padding:
                const EdgeInsets.only(left: MEDIUM_PADDING, top: SMALL_PADDING),
            child: Text(
              'No groups available for this type of task yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        SizedBox(
          height: 100,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _groupScrollController,
            child: ListView.builder(
              controller: _groupScrollController,
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups.elementAt(index);
                return GroupSuggestionTile(
                  group: group,
                  active: true,
                  selected: _selectedGroup == group,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedGroup = group;
                      } else {
                        _selectedGroup = null;
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    bool isEnabled = false;

    if (_taskType == KeyType.signChallenge) {
      isEnabled = _selectedGroup != null &&
          _descController.text.isNotEmpty &&
          _messageController.text.isNotEmpty;
    }

    if (_taskType == KeyType.decrypt) {
      if (_showImageSelector) {
        isEnabled = _selectedGroup != null &&
            _descController.text.isNotEmpty &&
            _image != null;
      } else {
        isEnabled = _selectedGroup != null &&
            _descController.text.isNotEmpty &&
            _messageController.text.isNotEmpty;
      }
    }

    if (_taskType == KeyType.signPdf) {
      isEnabled = _selectedGroup != null && _pdfFile != null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: LARGE_GAP, left: MEDIUM_PADDING),
      child: FilledButton.icon(
        onPressed: isEnabled
            ? () {
                if (_taskType == KeyType.signChallenge) {
                  _createChallenge(context);
                } else if (_taskType == KeyType.decrypt) {
                  _createDecryption(context);
                } else if (_taskType == KeyType.signPdf) {
                  _createPdfTask(context);
                }
              }
            : null,
        label: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text('Create ${_getTaskTypeDescription()} task'),
        ),
        icon: const Icon(
          Icons.send_rounded,
        ),
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Select PDF",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(width: MEDIUM_GAP),
            OutlinedButton(
              child: Text(_pdfFile == null ? "Choose file" : "Change file"),
              onPressed: () async {
                _pdfFile = await PdfPicker.pickPdfFile();
                setState(() {
                  if (_pdfFile == null) return;
                });

                if ((await _pdfFile?.length())! > AppViewModel.maxDataSize) {
                  if (context.mounted) {
                    showErrorDialog(
                      context: context,
                      title: 'File too large',
                      desc: 'Please select a smaller one.',
                    );
                  }
                  return;
                }
              },
            ),
          ],
        ),
        SizedBox(
          height: MEDIUM_GAP,
        ),
        if (_pdfFile != null) ...[
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() {
                    _pdfFile = null;
                  });
                },
              ),
              SizedBox(
                width: SMALL_GAP,
              ),
              Text(
                _pdfFile!.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ]
      ],
    );
  }

  Future<void> _selectImage(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    final header =
        bytes.sublist(0, min(defaultMagicNumbersMaxLength, bytes.length));
    final mimeTypeStr = lookupMimeType(file.path, headerBytes: header);

    if (bytes.length > AppViewModel.maxDataSize) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: 'Data too large',
          desc: 'Please select a smaller image or enter a shorter text.',
        );
      }
      return;
    }

    setState(() {
      _image = bytes;
      _imageMimeType = mimeTypeStr != null ? MimeType(mimeTypeStr) : null;
    });
  }

  void _createChallenge(BuildContext context) {
    var data = utf8.encode(_messageController.text);
    var description = _descController.text;

    try {
      final state = context.read<AppViewModel>();
      state.challenge(description, data, _selectedGroup!);
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: 'Challenge request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }

  void _createDecryption(BuildContext context) {
    var description = _descController.text;

    try {
      if (context.mounted) {
        final state = context.read<AppViewModel>();

        if (_showImageSelector) {
          state.encrypt(description, _imageMimeType!, _image!, _selectedGroup!);
        } else {
          var data = utf8.encode(_messageController.text);
          state.encrypt(description, MimeType.textUtf8, data, _selectedGroup!);
        }

        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: 'Decryption request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }

  void _createPdfTask(BuildContext context) {
    try {
      final state = context.read<AppViewModel>();
      state.sign(_pdfFile!, _selectedGroup!);
      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: 'Sign request failed',
          desc: 'Please try again.',
        );
      }
      rethrow;
    }
  }
}
