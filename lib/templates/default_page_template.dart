import 'package:flutter/material.dart';

import '../ui_constants.dart';

class DefaultPageTemplate extends StatelessWidget {
  final Widget body;
  final bool showAppBar;
  final String appBarTitle;
  final bool wrapInScroll;
  final String backButtonText;
  final bool includePadding;

  const DefaultPageTemplate({
    super.key,
    required this.body,
    this.showAppBar = false,
    this.appBarTitle = '',
    this.backButtonText = 'Back',
    this.wrapInScroll = false,
    this.includePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              forceMaterialTransparency: true,
              surfaceTintColor: Colors.transparent,
              leadingWidth: 120,
              leading: _buildCustomBackButton(context),
              title: Text(appBarTitle),
            )
          : null,
      body: Container(
        padding: EdgeInsets.all(includePadding ? MEDIUM_PADDING : 0),
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
              child: wrapInScroll
                  ? SingleChildScrollView(
                      child: body,
                    )
                  : body),
        ),
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
