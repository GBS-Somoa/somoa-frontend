import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/models/order_model.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
import 'package:somoa/widgets/order_widget.dart';

class OrderListScreen extends StatefulWidget {
  final int? groupId;

  OrderListScreen({super.key, this.groupId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  static const storage = FlutterSecureStorage();
  int groupId = 0;
  bool _isLoading = true;

  List<Order> orders = [];

  @override
  void initState() {
    super.initState();

    if (widget.groupId != null) {
      groupId = widget.groupId!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is int) {
          groupId = args;
        }
      });
    }
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await fetchOrders();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchOrders() async {
    final accessToken = await storage.read(key: 'accessToken');
    print('accessToken: $accessToken');
    print('groupId: $groupId');
    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups/${groupId}/orders');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        if (data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          setState(() {
            orders = ordersJson.map((order) => Order.fromJson(order)).toList();
          });
        }
      } else {
        print(json.decode(utf8.decode(response.bodyBytes)));
        print(response.statusCode);
        print('내가 주문한 주문목록 조회 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, Object> makeOrderInfo(Order order) {
    print('order.productImg: ${order.productImg}');
    return {
      'orderStore': order.orderStore,
      'productName': order.productName,
      'productImg': order.productImg,
      'orderStatus': order.orderStatus,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MenuBarWidget(titleText: '주문 목록'),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          // TODO : 주문 취소도 보여주기
          if (order.orderStatus != '주문취소') {
            return Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20.0), // 왼쪽에 20 픽셀의 패딩 추가
                    child: Text(
                      order.createdAt.toString().substring(0, 10),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  OrderWidget(orderInfo: makeOrderInfo(order)),
                ],
              ),
            );
          } else {
            return SizedBox(); // 주문 취소인 경우 아무 것도 렌더링하지 않음
          }
        },
      ),
    );
  }
}
