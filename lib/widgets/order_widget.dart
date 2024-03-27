import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  final Map<String, Object> orderInfo;

  OrderWidget({
    super.key,
    required this.orderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Text(
              orderInfo['orderDate'] as String,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(orderInfo['orderStore'] as String,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(orderInfo['productName'] as String),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      orderInfo['orderStatus'] == '결제완료'
                          ? 'assets/images/deliveryStatus=onlyPurchase.png'
                          : orderInfo['orderStatus'] == '배송시작'
                              ? 'assets/images/deliveryStatus=deliveryStart.png'
                              : orderInfo['orderStatus'] == '배송중'
                                  ? 'assets/images/deliveryStatus=deliveryIng.png'
                                  : 'assets/images/deliveryStatus=deliveryStart.png',
                      width: 150,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to shopping mall
                        },
                        child: Text(
                          '쇼핑몰로 이동',
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: Color.fromARGB(255, 23, 82, 134))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
