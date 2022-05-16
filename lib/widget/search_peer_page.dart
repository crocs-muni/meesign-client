import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/mpc_model.dart';

class SearchPeerPage extends StatefulWidget {
  const SearchPeerPage({Key? key}) : super(key: key);

  @override
  State<SearchPeerPage> createState() => _SearchPeerPageState();
}

class _SearchPeerPageState extends State<SearchPeerPage> {
  final _queryController = TextEditingController();
  List<Cosigner> _queryResults = [];

  void _query(String query) async {
    final model = context.read<MpcModel>();
    List<Cosigner> results = [];
    try {
      results = (await model.searchForPeers(_queryController.text)).toList();
    } catch (e) {}

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

  // TODO: this should probably be replaced with
  // ListView.builder() once the results get big
  Iterable<Widget> get _queryResultTiles sync* {
    yield ListTile(
      title: Text(
        'LOCAL NETWORK',
        style: Theme.of(context).textTheme.button,
      ),
    );

    for (final cosigner in _queryResults) {
      yield ListTile(
        leading: const Icon(Icons.person),
        title: Text(cosigner.name),
        onTap: () {
          Navigator.pop(context, cosigner);
        },
      );
    }
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
                child: ListView(
                  children: _queryResultTiles.toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
