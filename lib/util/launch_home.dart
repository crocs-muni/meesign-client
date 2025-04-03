import 'package:flutter/cupertino.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app/widget/tabbed_scaffold.dart';
import '../app_container.dart';
import 'fade_black_page_transition.dart';

Future<void> launchHome({
  required User user,
  required BuildContext context,
  bool registerNewUser = false,
  int delayMilliseconds = 500,
}) async {
  // Capture AppContainer and NavigatorState before async calls
  final container = context.read<AppContainer>();
  final navigator = Navigator.of(context, rootNavigator: true);

  if (registerNewUser) {
    await container.userRepository.setUser(user);
  }

  final currentSession = container.session;
  final session = currentSession != null && currentSession.user == user
      ? currentSession
      : await container.startUserSession(user);
  session.startSync();

  // Delay transition to show loading indicator inside button
  await Future.delayed(Duration(milliseconds: delayMilliseconds));

  navigator.pushAndRemoveUntil(
    FadeBlackPageTransition.fadeBlack(destination: TabbedScaffold()),
    (Route<dynamic> route) => false,
  );
}
