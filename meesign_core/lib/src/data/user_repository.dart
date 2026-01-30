import 'dart:typed_data';

import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_core/src/database/database.dart' as db;
import 'package:meesign_core/src/model/user.dart';
import 'package:meesign_core/src/util/uuid.dart';

class UserRepository {
  UserRepository(this._userDao);
  final UserDao _userDao;

  Future<User?> getUser({String searchedUserId = ''}) async {
    final entities = await _userDao.getAllUsers();
    db.User? entity;

    final list = searchedUserId.codeUnits;
    final bytes = Uint8List.fromList(list);

    for (final e in entities) {
      if (String.fromCharCodes(e.id) == String.fromCharCodes(bytes) ||
          searchedUserId == '') {
        entity = e;
        break;
      }
    }

    if (entity == null) return null;
    return User(Uuid(entity.id), entity.host);
  }

  Future<List<User>> getAllUsers() async {
    final entities = await _userDao.getAllUsers();
    return entities.map((e) => User(Uuid(e.id), e.host)).toList();
  }

  Future<void> setUser(User user) async {
    await _userDao.upsertUser(
      db.UsersCompanion.insert(
        id: user.did.bytes,
        host: user.host,
      ),
    );
  }

  Future<void> deleteUser(Uint8List searchedUserId) async {
    await _userDao.deleteUser(searchedUserId);
  }
}
