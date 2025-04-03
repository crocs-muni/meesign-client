import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/launch_home.dart';
import '../widget/confirmation_dialog.dart';

class ExistingUserList extends StatefulWidget {
  const ExistingUserList({super.key});

  @override
  ExistingUserListState createState() => ExistingUserListState();
}

class ExistingUserListState extends State<ExistingUserList> {
  bool _isEditing = false;
  bool _usersFetched = false;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    final container = context.read<AppContainer>();
    _users = await container.userRepository.getAllUsers();
    _usersFetched = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MEDIUM_PADDING, bottom: LARGE_PADDING),
      child: DefaultPageTemplate(
        appBarTitle: "Select account",
        showAppBar: true,
        body: Container(
          padding: EdgeInsets.all(MEDIUM_PADDING),
          child: _buildUserTable(),
        ),
        appBarActions: [
          _isEditing
              ? TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  label: Text(
                    "Confirm",
                  ),
                  icon: Icon(Icons.check),
                )
              : TextButton.icon(
                  onPressed: _users.isNotEmpty
                      ? () {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      : null,
                  label: Text(
                    "Edit",
                  ),
                  icon: Icon(Icons.edit),
                )
        ],
      ),
    );
  }

  Widget _buildUserTable() {
    if (!_usersFetched) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_users.isEmpty) {
      return _buildEmptyListPlaceholder();
    }

    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: SMALL_PADDING),
          child: Divider(
            color: Theme.of(context).colorScheme.onSecondary,
            height: 0,
          ),
        );
      },
      itemBuilder: (context, index) {
        return _buildUserRow(_users[index]);
      },
    );
  }

  Widget _buildDeleteButton(
    Uint8List userId,
  ) {
    return IconButton(
      onPressed: () {
        showConfirmationDialog(
            context,
            'Are you sure you want to delete this account?',
            'This will delete the selected device and all its communications. This action cannot be undone. ',
            'Delete', () async {
          final container = context.read<AppContainer>();
          container.userRepository.deleteUser(userId);

          fetchUsers();
        });
      },
      icon: Icon(
        Icons.delete_outline,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final inAnimation = Tween<Offset>(
      begin: Offset(0.5, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(animation);

    final outAnimation = Tween<Offset>(
      begin: Offset(-0.5, 0.0),
      end: Offset(0, 0.0),
    ).animate(animation);

    if (child.key == ValueKey('arrow')) {
      return SlideTransition(
        position: inAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    } else {
      return SlideTransition(
        position: outAnimation,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    }
  }

  Widget _buildEmptyListPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.supervisor_account,
            size: 120,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(height: SMALL_GAP),
          Text(
            "No accounts found",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: XLARGE_GAP),
        ],
      ),
    );
  }

  Widget _buildUserRow(User user) {
    const double actionButtonSize = 48;
    final container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    return ListTile(
        leading: Container(
          padding: EdgeInsets.only(right: SMALL_PADDING),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        title: FutureBuilder(
            future: settingsController
                .getNameById(String.fromCharCodes(user.did.bytes)),
            builder: (context, snapshot) {
              return Text(snapshot.data.toString());
            }),
        subtitle: Text(user.host),
        trailing: SizedBox(
          width: actionButtonSize,
          height: actionButtonSize,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return _buildTransition(child, animation);
            },
            child: _isEditing
                ? SizedBox(
                    key: ValueKey('delete'),
                    width: actionButtonSize,
                    height: actionButtonSize,
                    child: _buildDeleteButton(user.did.bytes),
                  )
                : SizedBox(
                    key: ValueKey('arrow'),
                    width: actionButtonSize,
                    height: actionButtonSize,
                    child: Center(
                      child: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
          ),
        ),
        onTap: _isEditing ? null : () => loginSelectedUser(user));
  }

  void loginSelectedUser(User user) async {
    await launchHome(user: user, context: context, registerNewUser: true);
  }
}
