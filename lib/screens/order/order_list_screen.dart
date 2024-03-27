import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/widgets/order_widget.dart';

class OrderListScreen extends StatefulWidget {
  final String groupId;

  OrderListScreen({required this.groupId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Map<String, Object>> orders = [
    {
      "orderId": 0,
      "orderStore": "SSAPANG",
      "productName": "다우니 세제 1L",
      "orderDate": "2024-03-25",
      "orderStatus": "배송완료"
    },
    {
      "orderId": 1,
      "orderStore": "SSAPANG",
      "productName": "다우니 세제 1L",
      "orderDate": "2024-03-25",
      "orderStatus": "결제완료"
    },
    {
      "orderId": 2,
      "orderStore": "삼성몰",
      "productName": "어쩌구저쩌구 정품 필터",
      "orderDate": "2024-03-25",
      "orderStatus": "결제완료"
    },
  ];

  @override
  void initState() {
    super.initState();
    // fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      // Send request to server with group ID
      final response = await http.get(
          Uri.parse('https://example.com/orders?groupId=${widget.groupId}'));

      if (response.statusCode == 200) {
        // Parse the response body and update the orders list
        final List<Map<String, Object>> data = jsonDecode(response.body);
        setState(() {
          orders = data;
        });
      } else {
        // Handle error response
        print('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Failed to fetch orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 목록'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          if (order['orderStatus'] != '주문취소') {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    order['orderDate'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  OrderWidget(orderInfo: order),
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
