import 'package:flutter/material.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/widget/device_selection_bar.dart';
import 'package:meesign_client/widget/device_suggestion_tile.dart';
import 'package:meesign_client/widget/no_results_placeholder.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage({
    required this.initialSelection,
    required this.currentDevice,
    super.key,
  });
  final List<Device> initialSelection;
  final Device currentDevice;

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  static const activeThreshold = Duration(seconds: 10);
  bool isReloading = false;

  final _queryController = TextEditingController();
  List<Device> _queryResults = [];
  DateTime _pivot = DateTime.now();
  bool _loaded = false;

  final List<Device> _selection = [];

  bool _isActive(Device device) => device.lastActive.isAfter(_pivot);

  List<Device> filterCurrentDevice({required List<Device> devices}) {
    return devices
        .where((device) => device.id != widget.currentDevice.id)
        .toList();
  }

  Future<void> _query(String query) async {
    Iterable<Device> results = [];
    try {
      final deviceRepository =
          context.read<AppContainer>().session!.deviceRepository;
      // TODO(dev): allow searching by id?

      // Fetch devices from server
      results = await deviceRepository.search(_queryController.text);

      // Filter out local devices (except current device)
      results = results
          .where((dev) => !dev.isLocal || dev.id == widget.currentDevice.id);

      setState(() => _loaded = true);
    } on Exception catch (_) {}

    _pivot = DateTime.now().subtract(activeThreshold);
    final active =
        filterCurrentDevice(devices: results.where(_isActive).toList());
    final inactive = filterCurrentDevice(
      devices: results.where((dev) => !_isActive(dev)).toList(),
    );

    // TODO(dev): consider moving this computation to a separate isolate
    int cmp(Device a, Device b) => a.name.compareTo(b.name);
    active.sort(cmp);
    inactive.sort(cmp);

    setState(() {
      _queryResults = active + inactive;
    });
  }

  Future<void> _refresh() async {
    // TODO(dev): Implement auto-refresh so user doesn't have to manually reload
    _query(_queryController.text);

    if (isReloading) return;

    setState(() {
      isReloading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isReloading = false;
      });
    });
  }

  void _changeSelection(Device device, bool value) {
    if (value) {
      if (_selection.any((elem) => elem.id == device.id)) return;
      setState(() => _selection.add(device));
    } else {
      setState(() => _selection.removeWhere((elem) => elem.id == device.id));
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize the selection with the initial selection
    _selection.addAll(widget.initialSelection);

    _queryController.addListener(() {
      _query(_queryController.text);
    });
    _query('');
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO(dev): migrate to showSearch/SearchDelegate?
    return DefaultPageTemplate(
      showAppBar: true,
      includePadding: false,
      customAppBar: AppBar(
        title: _buildDeviceSearchBar(),
        actions: [_buildAddButton()],
        bottom: _queryResults.isNotEmpty
            ? DeviceSelectionBar(
                showNoPeerSelected: _queryResults.isNotEmpty,
                devices: filterCurrentDevice(devices: _selection),
                onDeleted: (device) => _changeSelection(device, false),
              )
            : null,
      ),
      body: isReloading
          ? const LinearProgressIndicator()
          : _queryResults.isEmpty
              ? !_loaded
                  ? const LinearProgressIndicator()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: XLARGE_GAP * 3),
                            child: NoResultsPlaceholder(
                              label: _queryController.text.isEmpty
                                  ? AppLocalizations.of(context)
                                      .noPeersExistOnServer
                                  : AppLocalizations.of(context)
                                      .noPeersWithSuchNameFound,
                              icon: _queryController.text.isEmpty
                                  ? Icons.device_unknown
                                  : Icons.search_off,
                            ),
                          ),
                        ],
                      ),
                    )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: _queryResults.length,
                    itemBuilder: (context, index) {
                      final device = _queryResults[index];
                      return DeviceSuggestionTile(
                        device: device,
                        active: _isActive(device),
                        // TODO(dev): don't recompute this?
                        selected:
                            _selection.any((elem) => elem.id == device.id),
                        onChanged: device.id == widget.currentDevice.id
                            ? _selection.any(
                                (elem) => elem.id == widget.currentDevice.id,
                              )
                                ? null
                                : (value) {
                                    if (value != null) {
                                      _changeSelection(device, value);
                                    }
                                  }
                            : (value) {
                                if (value != null) {
                                  _changeSelection(device, value);
                                }
                              },
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildAddButton() {
    return Row(
      children: [
        FilledButton(
          onPressed: filterCurrentDevice(devices: _selection).isEmpty
              ? null
              : () => Navigator.pop(context, _selection),
          child: Text(AppLocalizations.of(context).add),
        ),
        const SizedBox(width: SMALL_GAP),
        Padding(
          padding: const EdgeInsets.only(right: SMALL_PADDING),
          child: FilledButton(
            onPressed: isReloading ? null : _refresh,
            child: Text(AppLocalizations.of(context).reload),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSearchBar() {
    return TextField(
      controller: _queryController,
      maxLength: 50,
      buildCounter: (
        _, {
        required int currentLength,
        required bool isFocused,
        maxLength,
      }) {
        return null; // Disable the counter
      },
      decoration: InputDecoration.collapsed(
        hintText: AppLocalizations.of(context).searchForPeer,
      ),
      autofocus: true,
    );
  }
}
