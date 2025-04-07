import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/launch_home.dart';
import '../util/set_user_login_prefereces.dart';
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
  List<int> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    final container = context.read<AppContainer>();
    _users = await container.userRepository.getAllUsers();
    _usersFetched = true;

    if (_users.isEmpty) {
      _isEditing = false;
    }
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
                      if (_selectedUsers.isNotEmpty) {
                        triggerDeleteUserDialog();
                        return;
                      } else {
                        _isEditing = false;
                        _selectedUsers = [];
                      }
                    });
                  },
                  label: Text(
                    _selectedUsers.isEmpty ? 'Cancel' : 'Delete',
                    style: TextStyle(
                        color:
                            _selectedUsers.isEmpty ? null : Colors.redAccent),
                  ),
                  icon: Icon(
                    _selectedUsers.isEmpty ? Icons.close : Icons.delete,
                    color: _selectedUsers.isEmpty ? null : Colors.redAccent,
                  ),
                )
              : TextButton.icon(
                  onPressed: _users.isNotEmpty
                      ? () {
                          setState(() {
                            _isEditing = true;
                            _selectedUsers = [];
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

    return SlidableAutoCloseBehavior(
      child: ListView.separated(
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
          return Slidable(
            key: ValueKey('userRow-$index'),
            enabled: !_isEditing,
            closeOnScroll: true,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  autoClose: true,
                  onPressed: (BuildContext context) {
                    triggerDeleteUserDialog(specificUserIndex: index);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: _buildUserRow(_users[index], index),
          );
        },
      ),
    );
  }

  Widget _buildDeleteButton(User user, int index) {
    // build checkbox
    return IconButton(
      onPressed: () {
        setState(() {
          if (_selectedUsers.contains(index)) {
            _selectedUsers.remove(index);
          } else {
            _selectedUsers.add(index);
          }
        });
      },
      icon: Icon(
        _selectedUsers.contains(index)
            ? Icons.check_box
            : Icons.check_box_outline_blank,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void triggerDeleteUserDialog({int? specificUserIndex}) {
    bool multiDelete = _selectedUsers.length > 1;

    showConfirmationDialog(
        context,
        'Are you sure you want to delete ${multiDelete ? 'these devices?' : 'this device?'}',
        'This will delete the selected ${multiDelete ? 'devices' : 'device'} and all its communications. This action cannot be undone. ',
        'Delete', () async {
      final container = context.read<AppContainer>();

      if (specificUserIndex != null) {
        _selectedUsers.add(specificUserIndex);
      }

      for (int index in _selectedUsers) {
        User user = _users[index];
        await container.deleteDevice(user.did);

        // Since container.deleteDevice() uses user session, which we don't have, we also
        // have to manually delete the device from the local db.
        var tempSession = await container.createAnonymousSession(user.host);
        await tempSession.deviceRepository.deleteLocalDevice(user.did.bytes);
      }

      setState(() {
        try {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            width: 350,
            behavior: SnackBarBehavior.floating,
            content: Text(
                'Deleted ${_selectedUsers.length} ${multiDelete ? 'devices' : 'device'}.'),
          ));
        } catch (e) {
          // ignore: avoid_print
          print(e);
        }

        _selectedUsers = [];
        _isEditing = false;

        fetchUsers();
      });
    });
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

  Widget _buildUserRow(User user, int index) {
    const double actionButtonSize = 48;
    final container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;
    String name = "";

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
            name = snapshot.data ?? "";
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
                  child: _buildDeleteButton(user, index),
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
      onTap: _isEditing
          ? () {
              setState(() {
                if (_selectedUsers.contains(index)) {
                  _selectedUsers.remove(index);
                } else {
                  _selectedUsers.add(index);
                }
              });
            }
          : () => loginSelectedUser(user, name),
    );
  }

  void loginSelectedUser(User user, String name) async {
    updateUserSessionPreferences(
      user.did.bytes,
      name,
      user.host,
      context,
    );
    await launchHome(user: user, context: context, registerNewUser: false);
  }
}
