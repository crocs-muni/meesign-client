import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meesign_client/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test common user workflow', () {
    testWidgets('Create a new user with a new group', (tester) async {
      // FIXME how to specify the arguments
      List<String> arguments = [];
      app.main(arguments);

      // String username = String.fromEnvironment("MEESIGN_USER");//, defaultValue: "Jan Novak");
      String username = "b";

      await tester.pumpAndSettle();

      final Finder nameField = find.byKey(Key("registration:textfield:name"));
      await tester.tap(nameField);
      await tester.enterText(nameField, username);

      final Finder hostField = find.byKey(Key("registration:textfield:host"));
      await tester.tap(hostField);
      await tester.enterText(hostField, 'localhost');
      // await tester.wait(find.text('localhost'));

      // // Finds the floating action button to tap on.
      final Finder registerButton =
          find.byKey(Key('registration:button:register'));
      await tester.tap(registerButton);

      await tester.pumpAndSettle();

      // expect(find.byKey(Key('homepage')), findsOneWidget);
      // expect(find.text(username), findsOneWidget);

      final Finder groupsTab = find.byKey(Key("homepage:groups"));
      await tester.tap(groupsTab);

      await tester.pumpAndSettle();
      final Finder newGroupButton = find.byKey(Key("homepage:new"));
      await tester.tap(newGroupButton);

      await tester.pumpAndSettle();

      final Finder newGroupName = find.byKey(Key("groups:textfield:name"));
      await tester.tap(newGroupName);
      await tester.enterText(newGroupName, 'test group');

      final Finder newMemberButton =
          find.byKey(Key("new_group_page:new_member"));
      await tester.tap(newMemberButton);

      await tester.pumpAndSettle();

      final Finder searchPeer = find.byKey(Key("new_group_page:search_peer"));
      await tester.tap(searchPeer);

      await tester.pumpAndSettle();
      final Finder searchedUser = find.byKey(Key("search_peer_page:$username"));
      await tester.tap(searchedUser);

      await tester.pumpAndSettle();
      final Finder createGroup = find.byKey(Key("new_group_page:create_group"));
      await tester.tap(createGroup);
    });
  });
}
