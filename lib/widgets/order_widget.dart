import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  late Map<String, Object> orderInfo;

  const OrderWidget({
    super.key,
    required this.orderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(orderInfo['storeName']),
          Text(orderInfo['productName']),
          Image.asset(
            'assets/images/$orderStatus.png',
            height: 100,
            width: 100,
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to shopping mall
            },
            child: Text('Go to Shopping Mall'),
          ),
        ],
      ),
    );
  }
}
