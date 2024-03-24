// providers/user_provider.dart
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = "";

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  void login(String username) {
    _isLoggedIn = true;
    _username = username;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _username = "";
    notifyListeners();
  }
}
