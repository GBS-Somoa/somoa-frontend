class RecentOrder {
  final int orderId;
  final String supplyId;
  final String orderStatus;
  final String orderStore;
  final String orderStoreId;
  final String productName;
  final String productImg;
  final int orderCount;
  final String orderAmount;
  final String createdAt;

  RecentOrder({
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

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      orderId: json["orderId"],
      supplyId: json["supplyId"],
      orderStatus: json["orderStatus"],
      orderStore: json["orderStore"],
      orderStoreId: json["orderStoreId"],
      productName: json["productName"],
      productImg: json["productImg"],
      orderCount: json["orderCount"],
      orderAmount: json["orderAmount"],
      createdAt: json["createdAt"],
    );
  }
}
