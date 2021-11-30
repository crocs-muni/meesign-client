import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPeerPage extends StatelessWidget {
  const SearchPeerPage({Key? key}) : super(key: key);

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
                  children: const [
                    BackButton(),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: 'Search for peer',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          'LOCAL NETWORK',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.network_wifi),
                        title: Text('192.168.1.5'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
