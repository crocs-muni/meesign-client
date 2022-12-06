import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:meesign_client/main.dart' as app;

import 'package:meesign_core/meesign_core.dart';
import 'package:meesign_core/src/model/key_type.dart';
import 'package:meta/meta.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() {
  late var server;

  setUp(() async {
    server = await Process.start(
      'meesign-server',
      [],
      mode: ProcessStartMode.detached,
    );
  });

  tearDown(() async {
    server.kill();
  });

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test common user workflow', () {
    testWidgets('Create a new user with a new group', (tester) async {
      // FIXME how to specify the arguments
      List<String> arguments = [];
      app.main(arguments);

      String username_GUI = "AUser";

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
    });
  });
}
