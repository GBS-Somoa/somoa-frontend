import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_id/android_id.dart';

class UserProvider with ChangeNotifier {
  String? _username = "";
  String? _nickname = "";

  String? get username => _username;
  String? get nickname => _nickname;

  final storage = const FlutterSecureStorage();

  Future<String?> login({
    required bool keepLoggedIn,
    required String username,
    required String password,
  }) async {
    String url = dotenv.get("SERVER_URL");

    final fcmToken = await storage.read(key: 'fcmToken');

    const androidIdPlugin = AndroidId();
    final String? androidId = await androidIdPlugin.getId();

    Map<String, String> data = {
      'username': username,
      'password': password,
      'mobileDeviceId': androidId ?? '',
      'fcmToken': fcmToken ?? ''
    };

    try {
      final response = await http.post(
        Uri.parse('${url}user/login'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        _username = username;
        _nickname = responseBody['data']['nickname'];
        final accessToken = responseBody['data']['accessToken'];
        final refreshToken = responseBody['data']['refreshToken'];

        if (keepLoggedIn) {
          await storage.write(key: 'username', value: username);
          await storage.write(key: 'password', value: password);
        }

        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);

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

  Future<Map<String, dynamic>> checkLoginAndInitialMessage() async {
    bool isLoggedIn = await autoLogin();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    return {
      'isLoggedIn': isLoggedIn,
      'hasInitialMessage': initialMessage != null,
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', false);

    _username = null;

    await storage.delete(key: 'username');
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');

    notifyListeners();
  }

  Future<String?> signUp(
      {required String username,
      required String password,
      required String nickname}) async {
    String url = dotenv.get("SERVER_URL");

    Map<String, String> data = {
      'username': username,
      'password': password,
      'nickname': nickname
    };

    try {
      final response = await http.post(
        Uri.parse('${url}user/signup'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return "success";
      } else {
        return "중복된 아이디가 존재합니다.";
      }
    } catch (e) {
      return "회원가입 요청 중 오류가 발생했습니다.";
    }
  }
}
