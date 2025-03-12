import 'package:flutter/material.dart';

class DefaultPageTemplate extends StatelessWidget {
  final Widget body;

  const DefaultPageTemplate({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: SafeArea(
            child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context)
                  .size
                  .height, // Ensure at least full screen height
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                      child: body), // Ensures that body fills available space
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
