import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _username = "";
  String? _nickname = "";
  late String? _accessToken;
  late String? _refreshToken;

  String? get username => _username;
  String? get nickname => _nickname;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  final storage = const FlutterSecureStorage();

  Future<String?> login({
    required bool keepLoggedIn,
    required String username,
    required String password,
  }) async {
    String url = dotenv.get("SERVER_URL");

    Map<String, String> data = {'username': username, 'password': password};

    try {
      final response = await http.post(
        Uri.parse('${url}user/login'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        _username = username;
        _nickname = responseBody['data']['nickname'];
        _accessToken = responseBody['data']['accessToken'];
        _refreshToken = responseBody['data']['refreshToken'];

        if (keepLoggedIn) {
          await storage.write(key: 'username', value: username);
          await storage.write(key: 'password', value: password);
        }

        await storage.write(key: 'accessToken', value: _accessToken);
        await storage.write(key: 'refreshToken', value: _refreshToken);

        notifyListeners();

        return "success";
      } else {
        return "아이디 또는 비밀번호가 올바르지 않습니다.";
      }
    } catch (e) {
      return "로그인 요청 중 오류가 발생했습니다.";
    }
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;

    if (!keepLoggedIn) {
      return false;
    }

    final username = await storage.read(key: 'username');
    final password = await storage.read(key: 'password');

    if (username == null || password == null) {
      return false;
    }

    final loginResult = await login(
      keepLoggedIn: keepLoggedIn,
      username: username,
      password: password,
    );

    if (loginResult == "success") {
      return true;
    } else {
      return false;
    }
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
