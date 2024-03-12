import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../theme.dart';
import '../util/chars.dart';
import '../widget/entity_chip.dart';

class DeviceSelectionBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Device> devices;
  final void Function(Device) onDeleted;

  const DeviceSelectionBar({
    super.key,
    required this.devices,
    required this.onDeleted,
  });

  @override
  State<DeviceSelectionBar> createState() => _DeviceSelectionBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _DeviceSelectionBarState extends State<DeviceSelectionBar> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.preferredSize.height,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          itemCount: widget.devices.length,
          itemBuilder: (context, index) {
            final device = widget.devices[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.topCenter,
                child: DeviceChip(
                  device: device,
                  onDeleted: () => widget.onDeleted(device),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DeviceSuggestionTile extends StatelessWidget {
  final Device device;
  final bool active;
  final bool selected;
  final void Function(bool?)? onChanged;

  const DeviceSuggestionTile({
    super.key,
    required this.device,
    this.active = false,
    this.selected = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: onChanged,
      secondary: Badge(
        backgroundColor: active
            ? Theme.of(context).extension<CustomColors>()!.success
            : Theme.of(context).colorScheme.error,
        smallSize: 8,
        child: CircleAvatar(
          child: Text(device.name.initials),
        ),
      ),
      title: Text(device.name),
      subtitle: Text(
        device.id.encode().splitByLength(4).join(' '),
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.26),
          fontFamily: 'RobotoMono',
        ),
      ),
    );
  }
}

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage({super.key});

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  static const activeThreshold = Duration(seconds: 10);

  final _queryController = TextEditingController();
  List<Device> _queryResults = [];
  DateTime _pivot = DateTime.now();

  final List<Device> _selection = [];

  bool _isActive(Device device) => device.lastActive.isAfter(_pivot);

  void _query(String query) async {
    Iterable<Device> results = [];
    try {
      final deviceRepository = context.read<AppContainer>().deviceRepository;
      // TODO: allow searching by id?
      results = await deviceRepository.search(_queryController.text);
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          decoration: const InputDecoration.collapsed(
            hintText: 'Search for peer',
          ),
          autofocus: true,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _selection.isEmpty
                  ? null
                  : () => Navigator.pop(context, _selection),
              child: const Text('Add'),
            ),
          ),
        ],
        bottom: _selection.isNotEmpty
            ? DeviceSelectionBar(
                devices: _selection,
                onDeleted: (device) => _changeSelection(device, false),
              )
            : null,
      ),
      body: ListView.builder(
        itemCount: _queryResults.length,
        itemBuilder: (context, index) {
          final device = _queryResults[index];
          return DeviceSuggestionTile(
            device: device,
            active: _isActive(device),
            // TODO: don't recompute this?
            selected: _selection.any((elem) => elem.id == device.id),
            onChanged: (value) {
              if (value != null) _changeSelection(device, value);
            },
          );
        },
      ),
    );
  }
}
