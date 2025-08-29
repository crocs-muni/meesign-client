import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/arb/app_localizations.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/actions/challenge_creator.dart';
import '../util/actions/document_signer.dart';
import '../util/actions/encrypt_data.dart';
import '../widget/copy_button.dart';
import '../widget/entity_chip.dart';
import '../widget/share_button.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage(
      {super.key,
      required this.task,
      required this.title,
      required this.group,
      required this.keyType,
      this.textValue,
      this.hexValue,
      this.imageDecrypt,
      this.timedAutoClose = false,
      this.autoCloseDurationInSeconds = 15,
      this.filePath,
      this.isArchived = false});

  final String title;
  final String? textValue;
  final String? hexValue;
  final Decrypt? imageDecrypt;
  final bool timedAutoClose;
  final int autoCloseDurationInSeconds;
  final String? filePath;
  final Group group;
  final bool isArchived;
  final Task task;
  final KeyType keyType;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late final Duration duration;
  final refreshInterval = Duration(milliseconds: 20);
  final countdownSubject = BehaviorSubject<int>();
  late final int steps;
  late final StreamSubscription<int> sub;
  bool wasAutoClosed = false;

  @override
  void initState() {
    super.initState();

    duration = Duration(seconds: widget.autoCloseDurationInSeconds);
    steps = duration.inMilliseconds ~/ refreshInterval.inMilliseconds;
    final countdown =
        Stream.periodic(refreshInterval, (i) => max(0, steps - i));
    sub = countdown.listen((value) {
      countdownSubject.add(value);
      if (value == 0 && widget.timedAutoClose && !wasAutoClosed) {
        wasAutoClosed = true;
        _closePage();
      }
    });
  }

  void _closePage() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    } else if (mounted) {
      Future.delayed(Duration(milliseconds: 250), () => _closePage());
    }
  }

  @override
  void dispose() {
    sub.cancel();
    countdownSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
        showAppBar: true,
        includePadding: true,
        body: _buildPageBody(context),
        wrapInScroll: true,
        customAppBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: Row(
            children: [
              Text(AppLocalizations.of(context).taskDetail),
              if (widget.timedAutoClose) ...[
                SizedBox(width: MEDIUM_GAP),
                _buildLoadingIndicator(context),
              ]
            ],
          ),
        ));
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return StreamBuilder(
      stream: countdownSubject.stream,
      builder: (context, snapshot) {
        return Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              value: (snapshot.data ?? steps) / steps,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpenFileSection({
    required BuildContext context,
    required String title,
  }) {
    return FilledButton.icon(
      onPressed: () {
        _openFile(widget.filePath!);
      },
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(AppLocalizations.of(context).openPdfFile),
      ),
      icon: Icon(Icons.open_in_new),
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context: context,
          title: widget.filePath == null
              ? AppLocalizations.of(context).taskName
              : AppLocalizations.of(context).fileName,
          content: widget.title,
          showCopyButton: false,
        ),
        if (widget.textValue != null) ...[
          const SizedBox(height: SMALL_GAP),
          _buildSection(
            context: context,
            title: AppLocalizations.of(context).taskValue,
            content: widget.textValue!,
            showCopyButton: true,
          ),
        ],
        if (widget.imageDecrypt != null) ...[
          const SizedBox(height: SMALL_GAP),
          _buildImageSection(
            context: context,
            title: AppLocalizations.of(context).taskImage,
            imageData: widget.imageDecrypt!.data,
          ),
        ],
        if (widget.filePath != null) ...[
          const SizedBox(height: SMALL_GAP),
          _buildOpenFileSection(
            context: context,
            title: 'PDF file',
          ),
        ],
        if (widget.hexValue != null) ...[
          const SizedBox(height: SMALL_GAP),
          _buildSection(
            context: context,
            title: AppLocalizations.of(context).hexValue,
            content: widget.hexValue!,
            showCopyButton: true,
          ),
        ],
        const SizedBox(height: MEDIUM_GAP),
        if (widget.isArchived) ...[
          _buildSection(
              title: AppLocalizations.of(context).taskState,
              context: context,
              content: AppLocalizations.of(context).archived,
              showCopyButton: false),
        ],
        const SizedBox(height: MEDIUM_GAP),
        _buildGroupSection(context: context, group: widget.group),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () async {
            sub.pause();
            bool? redirectBack = false;
            if (widget.keyType == KeyType.signChallenge) {
              redirectBack = await createChallenge(
                  context: context,
                  buildContext: context,
                  templateChallenge: widget.task);
            } else if (widget.keyType == KeyType.decrypt) {
              redirectBack = await encryptData(
                  context: context,
                  buildContext: context,
                  templateDecryptTask: widget.task);
            } else if (widget.keyType == KeyType.signPdf) {
              redirectBack = await signDocument(
                  context: context,
                  buildContext: context,
                  templateSignTask: widget.task);
            }

            sub.resume();

            if (redirectBack == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(AppLocalizations.of(context).useTemplateForTask),
          ),
          icon: const Icon(
            Icons.copy,
          ),
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required BuildContext context,
    required String title,
    required List<int> imageData,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildHeader(context, title),
            Spacer(),
            if (widget.imageDecrypt != null) ...[
              ShareButton(
                imageDecrypt: widget.imageDecrypt,
                preShareAction: () => sub.pause(),
                postShareAction: () => sub.resume(),
              )
            ]
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
          child: Image.memory(imageData as Uint8List),
        ),
        SizedBox(height: SMALL_GAP),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    bool showCopyButton = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildHeader(context, title),
            Spacer(),
            if (showCopyButton) ...[
              CopyButton(textToCopy: content),
            ]
          ],
        ),
        Text(
          content,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(
          height: SMALL_GAP,
        )
      ],
    );
  }

  Widget _buildGroupSection({
    required BuildContext context,
    required Group group,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, AppLocalizations.of(context).taskGroup),
        SizedBox(height: SMALL_GAP),
        GroupChip(group: group),
      ],
    );
  }

  void _openFile(String path) {
    if (Platform.isLinux) {
      launchUrl(Uri.file(path));
    } else {
      OpenFilex.open(path);
    }
  }
}
