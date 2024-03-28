import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// secure storage를 이용하여 accessToken을 가져오는 코드
Future<String?> getAccessToken() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'accessToken');
}
