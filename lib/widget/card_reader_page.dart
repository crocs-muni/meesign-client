import 'package:flutter/material.dart';

class CardReaderPage extends StatefulWidget {
  const CardReaderPage({Key? key}) : super(key: key);

  @override
  _CardReaderPageState createState() => _CardReaderPageState();
}

class _CardReaderPageState extends State<CardReaderPage> {
  bool _working = true;
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
                  children: const [
                    BackButton(),
                  ],
                ),
              ),
              // TODO: this can overflow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      SizedBox.square(
                        dimension: 160,
                        child: CircularProgressIndicator(
                          value: _working ? null : 0,
                        ),
                      ),
                      const Icon(
                        Icons.contactless,
                        size: 100,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Hold the card near the back of the device',
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
