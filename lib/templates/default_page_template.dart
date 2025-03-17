import 'package:flutter/material.dart';

class DefaultPageTemplate extends StatelessWidget {
  final Widget body;
  final bool showAppBar;
  final String appBarTitle;
  final bool fullHeight;
  final String backButtonText;

  const DefaultPageTemplate({
    super.key,
    required this.body,
    this.showAppBar = false,
    this.appBarTitle = '',
    this.backButtonText = 'Back',
    this.fullHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              leadingWidth: 120,
              leading: _buildCustomBackButton(context),
              title: Text(appBarTitle),
            )
          : null,
      body: SizedBox(
        width: double.infinity,
        child: SafeArea(
            child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: fullHeight ? MediaQuery.of(context).size.height : 0,
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

  Widget? _buildCustomBackButton(BuildContext context) {
    return Navigator.canPop(context)
        ? Padding(
            padding: EdgeInsets.only(left: 0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              label: Text(backButtonText),
              icon: Icon(Icons.arrow_back),
            ),
          )
        : null;
  }
}
