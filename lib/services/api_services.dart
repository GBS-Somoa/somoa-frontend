import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//env파일로부터 SERVER_URL을 가져오는 코드
Future<String> getServerUrl() async {
  await dotenv.load();
  return dotenv.get("SERVER_URL");
}

// secure storage를 이용하여 accessToken을 가져오는 코드
Future<String?> getAccessToken() async {
  final storage = FlutterSecureStorage();
  return await storage.read(key: 'accessToken');
}
