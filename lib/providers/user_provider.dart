import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  String? _username = "";
  late String? _accessToken;
  late String? _refreshToken;

  String? get username => _username;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  final storage = const FlutterSecureStorage();

  Future<void> login(
      {required bool keepLoggedIn,
      required String username,
      required String password,
      required accessToken,
      required refreshToken}) async {
    _username = username;
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    // TODO : 로그인 유지 시의 로직 작성
    if (keepLoggedIn) {
      await storage.write(key: 'username', value: username);
      await storage.write(key: 'password', value: password);
    }

    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);

    notifyListeners();
  }

  Future<void> logout() async {
    _username = null;
    _accessToken = null;
    _refreshToken = null;

    await storage.delete(key: 'username');
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');

    notifyListeners();
  }
}
