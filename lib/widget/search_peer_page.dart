import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/mpc_model.dart';

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage({Key? key}) : super(key: key);

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  static const activeThreshold = Duration(seconds: 10);

  final _queryController = TextEditingController();
  List<Cosigner> _queryResults = [];
  DateTime _pivot = DateTime.now();

  bool _isActive(Cosigner cosigner) => cosigner.lastActive.isAfter(_pivot);

  void _query(String query) async {
    final model = context.read<MpcModel>();
    List<Cosigner> results = [];
    try {
      results = await model.searchForPeers(_queryController.text);
    } catch (e) {}

    _pivot = DateTime.now().subtract(activeThreshold);
    final active = results.where(_isActive).toList();
    final inactive = results.where((cos) => !_isActive(cos)).toList();

    cmp(Cosigner a, Cosigner b) => a.name.compareTo(b.name);
    active.sort(cmp);
    inactive.sort(cmp);

    results = active + inactive;

    setState(() {
      _queryResults = results;
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
    return Scaffold(
      body: SafeArea(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Search for peer',
                        ),
                        autofocus: true,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _queryResults.length,
                  itemBuilder: (context, index) {
                    final cosigner = _queryResults[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      trailing: Container(
                        width: 8,
                        decoration: ShapeDecoration(
                          color: _isActive(cosigner)
                              ? Colors.green
                              : Colors.orange,
                          shape: const CircleBorder(),
                        ),
                      ),
                      title: Text(cosigner.name),
                      onTap: () {
                        Navigator.pop(context, cosigner);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
