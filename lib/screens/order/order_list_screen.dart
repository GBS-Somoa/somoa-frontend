import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderListScreen extends StatefulWidget {
  final String groupId;

  OrderListScreen({required this.groupId});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> orders = [];

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
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          orders = data.map((item) => Order.fromJson(item)).toList();
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
        title: Text('Order List'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderWidget(order: orders[index]);
        },
      ),
    );
  }
}

class Order {
  final String id;
  final String name;
  // Add more properties as needed

  Order({required this.id, required this.name});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      name: json['name'],
      // Parse other properties from JSON
    );
  }
}

class OrderWidget extends StatelessWidget {
  final Order order;

  OrderWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(order.name),
      // Customize the widget as needed
    );
  }
}
