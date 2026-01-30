import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meesign_client/app_container.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/util/launch_home.dart';
import 'package:meesign_client/util/set_user_login_prefereces.dart';
import 'package:meesign_client/widget/confirmation_dialog.dart';
import 'package:meesign_client/widget/no_results_placeholder.dart';
import 'package:meesign_client/widget/skeletonizer_template.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:provider/provider.dart';

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

  Future<void> fetchUsers() async {
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
      color: Theme.of(context).colorScheme.surface,
      padding:
          const EdgeInsets.only(top: MEDIUM_PADDING, bottom: LARGE_PADDING),
      child: DefaultPageTemplate(
        transparentBackground: true,
        appBarTitle: AppLocalizations.of(context).selectAccount,
        showAppBar: true,
        body: Container(
          padding: const EdgeInsets.all(MEDIUM_PADDING),
          child: _buildUserTable(),
        ),
        appBarActions: [_buildAppBarEditAction()],
      ),
    );
  }

  Widget _buildAppBarEditAction() {
    return _isEditing
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
              _selectedUsers.isEmpty
                  ? AppLocalizations.of(context).cancel
                  : AppLocalizations.of(context).delete,
              style: TextStyle(
                color: _selectedUsers.isEmpty ? null : Colors.redAccent,
              ),
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
              AppLocalizations.of(context).edit,
            ),
            icon: const Icon(Icons.edit),
          );
  }

  Widget _buildUserTable() {
    if (!_usersFetched) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_users.isEmpty) {
      return NoResultsPlaceholder(
        label: AppLocalizations.of(context).noAccountsFound,
        icon: Icons.supervisor_account,
      );
    }

    return SlidableAutoCloseBehavior(
      child: ListView.separated(
        itemCount: _users.length,
        separatorBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: SMALL_PADDING),
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
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) {
                    triggerDeleteUserDialog(specificUserIndex: index);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: AppLocalizations.of(context).delete,
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
    final multiDelete = _selectedUsers.length > 1;

    showConfirmationDialog(
        context,
        multiDelete
            ? AppLocalizations.of(context).areYouSureDeleteDevices
            : AppLocalizations.of(context).areYouSureDeleteDevice,
        multiDelete
            ? AppLocalizations.of(context).deleteDevicesConfirmation
            : AppLocalizations.of(context).deleteDeviceConfirmation,
        AppLocalizations.of(context).delete, () async {
      final container = context.read<AppContainer>();

      if (specificUserIndex != null) {
        _selectedUsers.add(specificUserIndex);
      }

      for (final index in _selectedUsers) {
        final user = _users[index];
        await container.deleteDevice(user.did);

        // Since container.deleteDevice() uses user session, which we don't have, we also
        // have to manually delete the device from the local db.
        final tempSession = await container.createAnonymousSession(user.host);
        await tempSession.deviceRepository.deleteLocalDevice(user.did.bytes);
      }

      setState(() {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              width: 350,
              behavior: SnackBarBehavior.floating,
              content: Text(
                multiDelete
                    ? AppLocalizations.of(context)
                        .devicesDeleted(_selectedUsers.length)
                    : AppLocalizations.of(context)
                        .deviceDeleted(_selectedUsers.length),
              ),
            ),
          );
        } on Exception catch (e) {
          // Logging exception in non-critical UI callback.
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
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(animation);

    final outAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(animation);

    if (child.key == const ValueKey('arrow')) {
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

  Widget _buildUserRow(User user, int index) {
    const double actionButtonSize = 48;
    final container = context.read<AppContainer>();
    final settingsController = container.settingsController;
    var name = '';

    return FutureBuilder(
      future:
          settingsController.getNameById(String.fromCharCodes(user.did.bytes)),
      builder: (context, snapshot) {
        name = snapshot.data ?? '';
        return SkeletonizerTemplate(
          isLoading: !snapshot.hasData,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.only(right: SMALL_PADDING),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  name.initials,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            title: Text(name),
            subtitle: Text(user.host),
            trailing: SizedBox(
              width: actionButtonSize,
              height: actionButtonSize,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: _buildTransition,
                child: _isEditing
                    ? SizedBox(
                        key: const ValueKey('delete'),
                        width: actionButtonSize,
                        height: actionButtonSize,
                        child: _buildDeleteButton(user, index),
                      )
                    : const SizedBox(
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
          ),
        );
      },
    );
  }

  Future<void> loginSelectedUser(User user, String name) async {
    updateUserSessionPreferences(
      user.did.bytes,
      name,
      user.host,
      context,
    );
    await launchHome(user: user, context: context);
  }
}
