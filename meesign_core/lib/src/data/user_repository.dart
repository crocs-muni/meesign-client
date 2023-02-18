import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/user.dart';
import '../util/uuid.dart';

class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  Future<User?> getUser() async {
    final entity = await _userDao.getUser();
    if (entity == null) return null;
    return User(Uuid(entity.id), entity.host);
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
