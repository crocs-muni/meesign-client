import 'package:flutter/material.dart';
import 'package:meesign_client/enums/screen_layout.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/layout_getter.dart';

class DefaultPageTemplate extends StatelessWidget {
  const DefaultPageTemplate({
    required this.body,
    super.key,
    this.floatingActionButton,
    this.customAppBar,
    this.showAppBar = false,
    this.appBarTitle = '',
    this.backButtonText = '',
    this.wrapInScroll = false,
    this.includePadding = true,
    this.transparentBackground = false,
    this.appBarActions = const [],
    this.onBackButtonPressed,
  });
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
  final Function? onBackButtonPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = LayoutGetter.getCurLayout(constraints.maxWidth) ==
            ScreenLayout.mobile;

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
                    centerTitle: isMobile,
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
                    : body,
              ),
            ),
          ),
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }

  Widget? _buildCustomBackButton(BuildContext context) {
    return Navigator.canPop(context)
        ? Padding(
            padding: EdgeInsets.zero,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onBackButtonPressed?.call();
              },
              label: Text(
                backButtonText == ''
                    ? AppLocalizations.of(context).back
                    : backButtonText,
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          )
        : null;
  }
}
