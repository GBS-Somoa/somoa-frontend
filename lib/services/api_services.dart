import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/screens/order/recent_order.dart';

// secure storage를 이용하여 accessToken을 가져오는 코드
Future<String?> getAccessToken() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'accessToken');
}

// 최근 소모품 구매 내역을 가져오는 코드
Future<List<RecentOrder>> getRecentOrder(String supplyId) async {
  final accessToken = await getAccessToken();
  String serverUrl = dotenv.get("SERVER_URL");
  final url = Uri.parse('$serverUrl' 'orders?supply_id=$supplyId?size=1');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (data["data"] != null) {
      final List<dynamic> json = data['data'];
      return json.map((r) => RecentOrder.fromJson(r)).toList();
    }
    return [];
  }
  throw Error();
}
