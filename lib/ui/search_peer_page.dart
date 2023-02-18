import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../util/chars.dart';

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage({Key? key}) : super(key: key);

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  static const activeThreshold = Duration(seconds: 10);

  final _queryController = TextEditingController();
  List<Device> _queryResults = [];
  DateTime _pivot = DateTime.now();

  bool _isActive(Device device) => device.lastActive.isAfter(_pivot);

  void _query(String query) async {
    Iterable<Device> results = [];
    try {
      final deviceRepository = context.read<AppContainer>().deviceRepository;
      results = await deviceRepository.search(_queryController.text);
    } catch (_) {}

    _pivot = DateTime.now().subtract(activeThreshold);
    final active = results.where(_isActive).toList();
    final inactive = results.where((dev) => !_isActive(dev)).toList();

    cmp(Device a, Device b) => a.name.compareTo(b.name);
    active.sort(cmp);
    inactive.sort(cmp);

    setState(() {
      _queryResults = active + inactive;
    });
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
      ),
      body: ListView.builder(
        itemCount: _queryResults.length,
        itemBuilder: (context, index) {
          final device = _queryResults[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(device.name.initials),
            ),
            trailing: Container(
              width: 8,
              decoration: ShapeDecoration(
                color: _isActive(device) ? Colors.green : Colors.orange,
                shape: const CircleBorder(),
              ),
            ),
            title: Text(device.name),
            onTap: () {
              Navigator.pop(context, device);
            },
          );
        },
      ),
    );
  }
}
