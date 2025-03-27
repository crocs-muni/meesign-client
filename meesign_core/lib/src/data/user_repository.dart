import 'dart:typed_data';

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/user.dart';
import '../util/uuid.dart';

class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  Future<User?> getUser({String searchedUserId = ''}) async {
    final entities = await _userDao.getAllUsers();
    db.User? entity;

    List<int> list = searchedUserId.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);

    for (var e in entities) {
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
}
