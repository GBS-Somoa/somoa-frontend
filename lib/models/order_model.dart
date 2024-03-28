import 'package:flutter/cupertino.dart';

class Order {
  final int orderId;
  final String supplyId;
  final String orderStatus;
  final String orderStore;
  final String orderStoreId;
  final String productName;
  final String productImg;
  final int orderCount;
  final String orderAmount;
  final DateTime createdAt;

  Order({
    required this.orderId,
    required this.supplyId,
    required this.orderStatus,
    required this.orderStore,
    required this.orderStoreId,
    required this.productName,
    required this.productImg,
    required this.orderCount,
    required this.orderAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      supplyId: json['supplyId'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderStore: json['orderStore'] ?? '',
      orderStoreId: json['orderStoreId'] ?? '',
      productName: json['productName'] ?? '',
      productImg: json['productImg'] != null && json['productImg'].startsWith('http')
          ? json['productImg']
          : 'https://i.ibb.co/K9B80fg/no-image.jpg',
      orderCount: json['orderCount'],
      orderAmount: json['orderAmount'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
