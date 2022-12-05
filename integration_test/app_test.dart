import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meesign_client/main.dart' as app;

import 'package:meesign_core/meesign_core.dart';
import 'package:meesign_core/src/model/key_type.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:io';

extension Approval<T> on TaskRepository<T> {
  StreamSubscription<Task<T>> approveAll(Uuid did,
      {required bool Function(Task<T>) agree}) {
    return observeTasks(did)
        .expand((tasks) => tasks)
        .where((task) => !task.approved)
        .listen((task) async {
      await approveTask(did, task.id, agree: agree(task));
    });
  }
}

class DummyFileStore implements FileStore {
  @override
  Future<String> getFilePath(Uuid did, Uuid id, String name) async => name;

  @override
  Future<String> storeFile(
          Uuid did, Uuid id, String name, List<int> data) async =>
      getFilePath(did, id, name);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test common user workflow', () {
    testWidgets('Create a new user with a new group', (tester) async {
      // FIXME how to specify the arguments
      List<String> arguments = [];
      app.main(arguments);

      // String username_GUI = String.fromEnvironment("MEESIGN_USER");//, defaultValue: "Jan Novak");
      String username_GUI = "AUser";

      final client = ClientFactory.create("localhost", allowBadCerts: true);
      final taskSource = TaskSource(client);
      final deviceRepository = DeviceRepository(client);
      final groupRepository =
          GroupRepository(client, taskSource, deviceRepository);
      final fileRepository =
          FileRepository(client, taskSource, DummyFileStore(), groupRepository);
      final challengeRepository =
          ChallengeRepository(taskSource, groupRepository);

      String helpUser = "BUser";
      final device = await deviceRepository.register(helpUser);
      print('Registered as ${device.name}');
      groupRepository.approveAll(device.id, agree: (_) => true);
      fileRepository.approveAll(device.id, agree: (_) => true);

      await tester.pumpAndSettle();

      final Finder nameField = find.byKey(Key("registration:textfield:name"));
      await tester.tap(nameField);
      await tester.enterText(nameField, username_GUI);

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
      // expect(find.text(username_GUI), findsOneWidget);

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
      final Finder searchedUserSelf =
          find.byKey(Key("search_peer_page:$username_GUI"));
      await tester.tap(searchedUserSelf);

      await tester.pumpAndSettle();
      await tester.tap(searchPeer);

      await tester.pumpAndSettle();
      final Finder searchedUserB =
          find.byKey(Key("search_peer_page:$helpUser"));
      await tester.tap(searchedUserB);
      await tester.pumpAndSettle();

      // FIXME relying on offsets is a fragile approach
      await tester.tapAt(Offset(10, 10));
      await tester.pumpAndSettle();

      // await tester.pump(new Duration(milliseconds: 2000));
      final Finder createGroup = find.byKey(Key("new_group_page:create_group"));
      await tester.tap(createGroup);
      await tester.pumpAndSettle();

      final Finder groupJoin = find.byKey(Key("groups:subpage:join"));
      await tester.tap(groupJoin);
      await tester.pumpAndSettle();

      // maybe wait?
      // await tester.pump(new Duration(milliseconds: 2000));
      // 1. go to signing windonw
      final Finder signing = find.byKey(Key("homepage:signing"));
      await tester.tap(signing);
      await tester.pumpAndSettle();
      // 2. sign button
      final Finder signPDF = find.byKey(Key("SignFab"));
      await tester.tap(signPDF);
      await tester.pumpAndSettle();
      // 3. select a file
      // 4. select a test group
      // 5. sign
      // 6. wait

      // await tester.pump(new Duration(milliseconds: 5000));
    });
  });
}
