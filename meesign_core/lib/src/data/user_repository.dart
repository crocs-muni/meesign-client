import '../model/user.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async => _user;

  Future<void> setUser(User user) async => _user = user;
}
