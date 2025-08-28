import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../enums/task_type.dart';
import '../l10n/arb/app_localizations.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/group_creator.dart';
import '../util/pick_pdf_file.dart';
import '../util/platform.dart';
import '../view_model/app_view_model.dart';
import '../widget/error_dialog.dart';
import '../widget/group_suggestion_tile.dart';
import '../widget/option_tile.dart';
import 'groups_listing_page.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage(
      {super.key,
      this.initialTaskType,
      this.showTaskTypeSelector = false,
      this.templateTask});

  final KeyType? initialTaskType;
  final Task? templateTask;
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
  bool _isFromTemplate = false;
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

    if (widget.templateTask != null) {
      _createTaskFromTemplate();
    }
  }

  void _createTaskFromTemplate() {
    if (widget.templateTask == null) {
      return;
    }

    final template = widget.templateTask!;
    setState(() {
      _isFromTemplate = true;
      // Set task type based on template group's key type
      _taskType = template.info.group.keyType;
      _selectedGroup = template.info.group;

      // Restore task-specific data based on type
      if (template.info is Challenge) {
        final challengeInfo = template.info as Challenge;
        _descController.text =
            '${challengeInfo.name} ${AppLocalizations.of(context).copyNoun}';
        _messageController.text = utf8.decode(challengeInfo.data);
      } else if (template.info is Decrypt) {
        final decryptInfo = template.info as Decrypt;
        _descController.text =
            '${decryptInfo.name} ${AppLocalizations.of(context).copyNoun}';

        if (decryptInfo.dataType.isImage) {
          _showImageSelector = true;
          _image = Uint8List.fromList(decryptInfo.data);
          _imageMimeType = decryptInfo.dataType;
        } else {
          _showImageSelector = false;
          _messageController.text = utf8.decode(decryptInfo.data);
        }
      } else if (template.info is File) {
        final fileInfo = template.info as File;
        _descController.text =
            '${fileInfo.basename} ${AppLocalizations.of(context).copyNoun}';
        // Note: We can't restore the actual PDF file since we only have the path
        // The user will need to select the file again
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
      appBarTitle: AppLocalizations.of(context).createNewTaskTitle,
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
            thickness: 1,
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
      title: AppLocalizations.of(context).typeOfTask,
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
          segments: [
            ButtonSegment<KeyType>(
              value: KeyType.signPdf,
              label: Text(AppLocalizations.of(context).signPdf),
            ),
            ButtonSegment<KeyType>(
              value: KeyType.signChallenge,
              label: Text(AppLocalizations.of(context).challenge),
            ),
            ButtonSegment<KeyType>(
              value: KeyType.decrypt,
              label: Text(AppLocalizations.of(context).decrypt),
            )
          ],
        ),
      ],
    );
  }

  String _getTaskTypeDescription() {
    switch (_taskType) {
      case KeyType.signPdf:
        return AppLocalizations.of(context).pdfSigning;
      case KeyType.signChallenge:
        return AppLocalizations.of(context).challenge;
      case KeyType.decrypt:
        return AppLocalizations.of(context).decryption;
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
        return AppLocalizations.of(context).nameOfPdfSigningTask;
      case KeyType.signChallenge:
        return AppLocalizations.of(context).nameOfChallengeTask;
      case KeyType.decrypt:
        return AppLocalizations.of(context).nameOfDecryptionTask;
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
                hintText: AppLocalizations.of(context)
                    .enterDescriptionOfTask(_getTaskTypeDescription()),
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
          AppLocalizations.of(context).selectDecryptionType,
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
              label: AppLocalizations.of(context).decryptAMessage,
            ),
            _buildContentTypeRadio(
              initValue: true,
              onChanged: (value) {
                setState(() {
                  _showImageSelector = !value;
                });
              },
              label: AppLocalizations.of(context).decryptAnImage,
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
          child: Text(AppLocalizations.of(context).selectImage),
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
        return AppLocalizations.of(context).enterMessageToBeSigned;
      case KeyType.decrypt:
        return AppLocalizations.of(context).enterMessageToBeDecrypted;
      default:
        return AppLocalizations.of(context).enterMessage;
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
                hintText: AppLocalizations.of(context).enterTheMessage,
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
        if (_selectedGroup == null && groups.isNotEmpty && !_isFromTemplate) {
          _selectedGroup = groups.first;
        }

        // If the currently selected group is no longer available, reset it
        if (_selectedGroup != null &&
            !groups.contains(_selectedGroup) &&
            !_isFromTemplate) {
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
                      AppLocalizations.of(context).selectGroupForNewTask,
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
                    tooltip: AppLocalizations.of(context).refreshGroups,
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
                        AppLocalizations.of(context)
                            .noGroupsAvailableForTaskType,
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
                    final isSelected = _selectedGroup != null &&
                        const ListEquality()
                            .equals(_selectedGroup!.id, group.id);
                    return GroupSuggestionTile(
                      group: group,
                      active: true,
                      selected: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedGroup = group;
                            // Reset template flag after manual selection
                            if (_isFromTemplate) {
                              _isFromTemplate = false;
                            }
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
        return AppLocalizations.of(context).createGroupForPdfSigning;
      case KeyType.signChallenge:
        return AppLocalizations.of(context).createGroupForChallenges;
      case KeyType.decrypt:
        return AppLocalizations.of(context).createGroupForDecryption;
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
          child: Text(AppLocalizations.of(context)
              .createTaskButton(_getTaskTypeDescription())),
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
              AppLocalizations.of(context).selectPdf,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(width: MEDIUM_GAP),
            OutlinedButton(
              child: Text(_pdfFile == null
                  ? AppLocalizations.of(context).chooseFile
                  : AppLocalizations.of(context).changeFile),
              onPressed: () async {
                _pdfFile = await PdfPicker.pickPdfFile();
                setState(() {
                  if (_pdfFile == null) return;
                });

                if ((await _pdfFile?.length())! > AppViewModel.maxDataSize) {
                  if (context.mounted) {
                    showErrorDialog(
                      context: context,
                      title: AppLocalizations.of(context).fileTooLarge,
                      desc: AppLocalizations.of(context).pleaseSelectSmallerOne,
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
    XFile? file;

    if (PlatformGroup.isMobile) {
      // Use ImagePicker for mobile platforms (iOS/Android)
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else {
      // Use file_selector for desktop/web platforms (better Linux support)
      file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Images',
            extensions: const [
              'jpg',
              'jpeg',
              'png',
              'gif',
              'bmp',
              'webp',
              'svg'
            ],
          ),
        ],
      );
    }

    if (file == null) return;

    final bytes = await file.readAsBytes();

    final header =
        bytes.sublist(0, min(defaultMagicNumbersMaxLength, bytes.length));
    final mimeTypeStr = lookupMimeType(file.path, headerBytes: header);

    if (bytes.length > AppViewModel.maxDataSize) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).dataTooLarge,
          desc: AppLocalizations.of(context)
              .pleaseSelectSmallerImageOrShorterText,
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
      Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).challengeRequestFailed,
          desc: AppLocalizations.of(context).pleaseTryAgain,
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

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).decryptionRequestFailed,
          desc: AppLocalizations.of(context).pleaseTryAgain,
        );
      }
      rethrow;
    }
  }

  void _createPdfTask(BuildContext context) {
    try {
      final state = context.read<AppViewModel>();
      state.sign(_pdfFile!, _selectedGroup!);
      Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).signRequestFailed,
          desc: AppLocalizations.of(context).pleaseTryAgain,
        );
      }
      rethrow;
    }
  }
}
