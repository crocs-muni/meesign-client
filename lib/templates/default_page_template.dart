import 'package:flutter/material.dart';

import '../ui_constants.dart';

class DefaultPageTemplate extends StatelessWidget {
  final Widget body;
  final List<Widget> appBarActions;
  final bool showAppBar;
  final PreferredSizeWidget? customAppBar;
  final String appBarTitle;
  final bool wrapInScroll;
  final String backButtonText;
  final bool includePadding;
  final bool transparentBackground;
  final Widget? floatingActionButton;

  const DefaultPageTemplate({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.customAppBar,
    this.showAppBar = false,
    this.appBarTitle = '',
    this.backButtonText = 'Back',
    this.wrapInScroll = false,
    this.includePadding = true,
    this.transparentBackground = false,
    this.appBarActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparentBackground
          ? Colors.transparent
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar
          ? customAppBar ??
              AppBar(
                actions: appBarActions,
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
      floatingActionButton: floatingActionButton,
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
