import 'package:flutter/cupertino.dart';
import 'package:meesign_client/app/widget/tabbed_scaffold.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/util/fade_black_page_transition.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

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
  (currentSession != null && currentSession.user == user
          ? currentSession
          : await container.startUserSession(user))
      .startSync();

  // Delay transition to show loading indicator inside button
  await Future<void>.delayed(Duration(milliseconds: delayMilliseconds));

  navigator.pushAndRemoveUntil(
    FadeBlackPageTransition.fadeBlack(destination: const TabbedScaffold()),
    (Route<dynamic> route) => false,
  );
}
