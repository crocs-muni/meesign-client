import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../widget/device_selection_bar.dart';
import '../widget/device_suggestion_tile.dart';
import '../widget/no_results_placeholder.dart';

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage(
      {super.key, required this.initialSelection, required this.currentDevice});
  final List<Device> initialSelection;
  final Device currentDevice;

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  static const activeThreshold = Duration(seconds: 10);

  final _queryController = TextEditingController();
  List<Device> _queryResults = [];
  DateTime _pivot = DateTime.now();
  bool _loaded = false;

  final List<Device> _selection = [];

  bool _isActive(Device device) => device.lastActive.isAfter(_pivot);

  void _query(String query) async {
    Iterable<Device> results = [];
    try {
      final deviceRepository =
          context.read<AppContainer>().session!.deviceRepository;
      // TODO: allow searching by id?

      // Fetch devices from server
      results = await deviceRepository.search(_queryController.text);
      _loaded = true;

      // Fetch devices from local db
      // results = await deviceRepository.getAllLocalDevices();
    } catch (_) {}

    _pivot = DateTime.now().subtract(activeThreshold);
    final active = results.where(_isActive).toList();
    final inactive = results.where((dev) => !_isActive(dev)).toList();

    // TODO: consider moving this computation to a separate isolate
    cmp(Device a, Device b) => a.name.compareTo(b.name);
    active.sort(cmp);
    inactive.sort(cmp);

    setState(() {
      _queryResults = active + inactive;
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
    // TODO: migrate to showSearch/SearchDelegate?
    return DefaultPageTemplate(
      showAppBar: true,
      includePadding: false,
      customAppBar: AppBar(
          title: _buildDeviceSearchBar(),
          actions: [_buildAddButton()],
          bottom: DeviceSelectionBar(
            devices: _selection,
            onDeleted: (device) => _changeSelection(device, false),
          )),
      body: _queryResults.isEmpty
          ? !_loaded
              ? const Center(child: CircularProgressIndicator())
              : NoResultsPlaceholder(
                  label: "No peers with such a name found", icon: Icons.devices)
          : ListView.builder(
              itemCount: _queryResults.length,
              itemBuilder: (context, index) {
                final device = _queryResults[index];
                return DeviceSuggestionTile(
                  device: device,
                  active: _isActive(device),
                  // TODO: don't recompute this?
                  selected: _selection.any((elem) => elem.id == device.id),
                  onChanged: device.id == widget.currentDevice.id
                      ? null
                      : (value) {
                          if (value != null) _changeSelection(device, value);
                        },
                );
              },
            ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_PADDING),
      child: FilledButton(
        onPressed: _selection.isEmpty
            ? null
            : () => Navigator.pop(context, _selection),
        child: const Text('Add'),
      ),
    );
  }

  Widget _buildDeviceSearchBar() {
    return TextField(
      controller: _queryController,
      decoration: const InputDecoration.collapsed(
        hintText: 'Search for peer',
      ),
      autofocus: true,
    );
  }
}
