import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../ui_constants.dart';
import '../view_model/app_view_model.dart';
import '../widget/tab_selector_item.dart';
import 'challenge_listing_page.dart';
import 'decrypt_listing_page.dart';
import 'signing_listing_page.dart';

class TabbedTasksPage extends StatelessWidget {
  const TabbedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              toolbarHeight: 100,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: SMALL_PADDING),
                    child: Text(
                      'List of tasks',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  _buildHorizontalTabSelector(context)
                ],
              )),
          body: const TabBarView(
            children: [
              SigningListingPage(),
              ChallengeListingPage(),
              DecryptListingPage()
            ],
          ),
        ));
  }

  Widget _buildHorizontalTabSelector(BuildContext context) {
    return Container(
      height: kToolbarHeight - 8.0,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TabBar(
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.primary),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor:
            WidgetStateProperty.resolveWith((states) => Colors.transparent),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer,
        tabs: [
          TabSelectorItem(
              title: "Signing",
              stream: context.watch<AppViewModel>().nSignReqs,
              tabIcon: Icon(Symbols.draw)),
          TabSelectorItem(
              title: "Challenges",
              stream: context.watch<AppViewModel>().nChallengeReqs,
              tabIcon: Icon(Symbols.quiz)),
          TabSelectorItem(
              title: "Decryption",
              stream: context.watch<AppViewModel>().nDecryptReqs,
              tabIcon: Icon(Symbols.key))
        ],
      ),
    );
  }
}
