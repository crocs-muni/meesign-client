import 'package:flutter/material.dart';

import '../ui_constants.dart';

class ChangeDeviceSection extends StatelessWidget {
  const ChangeDeviceSection({super.key, required this.onChangeServer});
  final Function onChangeServer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Change server or device",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
        Text(
          "This will take you back to the registration screen where you can change the server or register a new device.",
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        SizedBox(height: MEDIUM_GAP),
        FilledButton.icon(
          onPressed: () {
            onChangeServer();
          },
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Change device'),
          ),
          icon: Icon(Icons.sync),
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
}
