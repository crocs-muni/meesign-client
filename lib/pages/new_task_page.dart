import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../enums/task_type.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/group_creator.dart';
import '../util/pick_pdf_file.dart';
import '../view_model/app_view_model.dart';
import '../widget/error_dialog.dart';
import '../widget/group_suggestion_tile.dart';
import '../widget/option_tile.dart';
import 'groups_listing_page.dart';

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
  bool _isRefreshingGroups = false;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _groupScrollController = ScrollController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialTaskType != null) {
      _taskType = widget.initialTaskType!;
    }

    // Start periodic refresh every second
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final state = context.read<AppViewModel>();
          state.refetchTasks(TaskType.group);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
      includePadding: false,
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
          SizedBox(height: XLARGE_GAP * 2)
        ],
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return OptionTile(
      title: 'Type of task',
      children: [
        SegmentedButton<KeyType>(
          showSelectedIcon: false,
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

  String _getTaskNameHeader() {
    switch (_taskType) {
      case KeyType.signPdf:
        return "Name of the PDF signing task";
      case KeyType.signChallenge:
        return "Name of the challenge task";
      case KeyType.decrypt:
        return "Name of the decryption task";
    }
  }

  Widget _buildTaskDesc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTaskNameHeader(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descController,
              maxLength: 100,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                counterText: '',
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

  Widget _buildContentTypeRadio({
    required ValueChanged<bool> onChanged,
    required String label,
    required bool initValue,
  }) {
    return Row(
      children: [
        Radio<bool>(
          value: initValue,
          groupValue: _showImageSelector,
          onChanged: (value) {
            onChanged(false);
          },
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              onChanged(false);
            },
            child: Text(label),
          ),
        )
      ],
    );
  }

  Widget _buildContentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select decryption type',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Wrap(
          spacing: LARGE_GAP,
          runSpacing: SMALL_GAP,
          children: [
            _buildContentTypeRadio(
              initValue: false,
              onChanged: (value) {
                setState(() {
                  _showImageSelector = value;
                });
              },
              label: 'Decrypt a message',
            ),
            _buildContentTypeRadio(
              initValue: true,
              onChanged: (value) {
                setState(() {
                  _showImageSelector = !value;
                });
              },
              label: 'Decrypt an image',
            ),
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

  String _getMessageFieldHeader() {
    switch (_taskType) {
      case KeyType.signChallenge:
        return "Enter message to be signed";
      case KeyType.decrypt:
        return "Enter message to be decrypted";
      default:
        return "Enter message";
    }
  }

  Widget _buildTaskMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getMessageFieldHeader(),
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
              maxLength: 100000,
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
    return Consumer<AppViewModel>(
      builder: (context, state, child) {
        final groups = state.groupTasks
            .where((task) =>
                task.state == TaskState.finished &&
                task.info.keyType == _taskType &&
                (state.showArchived ? true : !task.archived))
            .map((task) => task.info)
            .toList();

        // Select the first group of task type if none is selected
        if (_selectedGroup == null && groups.isNotEmpty) {
          _selectedGroup = groups.first;
        }

        // If the currently selected group is no longer available, reset it
        if (_selectedGroup != null && !groups.contains(_selectedGroup)) {
          _selectedGroup = groups.isNotEmpty ? groups.first : null;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: MEDIUM_PADDING, top: LARGE_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select group for the new task',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: _isRefreshingGroups
                        ? null
                        : () async {
                            setState(() {
                              _isRefreshingGroups = true;
                            });

                            try {
                              await state.refetchTasks(TaskType.group);
                              // Wait a bit for the database to update
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              // Force UI refresh
                              if (mounted) {
                                setState(() {});
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isRefreshingGroups = false;
                                });
                              }
                            }
                          },
                    icon: _isRefreshingGroups
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh groups',
                  ),
                ],
              ),
            ),
            if (groups.isEmpty) ...[
              Padding(
                  padding: const EdgeInsets.only(
                      left: MEDIUM_PADDING, top: SMALL_PADDING),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No groups available for this type of task yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: SMALL_GAP),
                      FilledButton.icon(
                        onPressed: () async {
                          // 1. Navigate to groups listing page
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GroupsListingPage(),
                          ));

                          // 2. Create a new group
                          await createGroup(context, context,
                              groupType: _getTaskType());
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(_getCreateGroupButtonText()),
                      ),
                    ],
                  )),
            ],
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
      },
    );
  }

  TaskType _getTaskType() {
    switch (_taskType) {
      case KeyType.signPdf:
        return TaskType.sign;
      case KeyType.signChallenge:
        return TaskType.challenge;
      case KeyType.decrypt:
        return TaskType.decrypt;
    }
  }

  String _getCreateGroupButtonText() {
    switch (_taskType) {
      case KeyType.signPdf:
        return 'Create group for PDF signing';
      case KeyType.signChallenge:
        return 'Create group for challenges';
      case KeyType.decrypt:
        return 'Create group for decryption';
    }
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
